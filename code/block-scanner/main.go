package main

import (
	"bytes"
	"context"
	"crypto/sha256"
	"database/sql"
	"html/template"
	"log"
	"net/http"
	"time"

	"github.com/gagliardetto/solana-go"
	"github.com/gagliardetto/solana-go/rpc"
	_ "github.com/mattn/go-sqlite3"
)

const (
	ProgramIDStr = "7UfykF9iXWorPS7A3SvgZmJzCTCxpVEqfLyBPw4K51YH"
	DBPath       = "./votes.db"
)

// VoteRecord represents a single vote to be displayed in the UI
type VoteRecord struct {
	Signature string
	Voter     string
	Proposal  string
	VoteType  string
	BlockTime string
}

// PageData holds the data for the HTML template
type PageData struct {
	Votes []VoteRecord
}

// getSighash computes the 8-byte Anchor instruction discriminator
func getSighash(name string) []byte {
	hasher := sha256.New()
	hasher.Write([]byte("global:" + name))
	return hasher.Sum(nil)[:8]
}

func main() {
	// Initialize SQLite database
	db, err := sql.Open("sqlite3", DBPath)
	if err != nil {
		log.Fatalf("Failed to open database: %v", err)
	}
	defer db.Close()

	// Create table for storing vote history
	createTableSQL := `CREATE TABLE IF NOT EXISTS votes (
		signature TEXT PRIMARY KEY,
		voter TEXT,
		proposal TEXT,
		vote_type TEXT,
		block_time INTEGER
	);`
	if _, err := db.Exec(createTableSQL); err != nil {
		log.Fatalf("Failed to create table: %v", err)
	}

	// Start the Web Server in a separate goroutine
	go startWebServer(db)

	// Setup Solana RPC client
	programID := solana.MustPublicKeyFromBase58(ProgramIDStr)
	client := rpc.New(rpc.DevNet_RPC)

	// Calculate the expected Instruction Data prefixes for "vote_yes" and "vote_no"
	voteYesSighash := getSighash("vote_yes")
	voteNoSighash := getSighash("vote_no")

	// Find the most recently processed signature from DB to avoid full rescan
	var lastProcessedSig solana.Signature
	var lastSigStr string
	err = db.QueryRow(`SELECT signature FROM votes ORDER BY block_time DESC LIMIT 1`).Scan(&lastSigStr)
	if err == nil && lastSigStr != "" {
		lastProcessedSig, err = solana.SignatureFromBase58(lastSigStr)
		if err != nil {
			log.Printf("Failed to parse last signature from DB: %v", err)
		} else {
			log.Printf("Resuming from signature: %s", lastProcessedSig)
		}
	}

	log.Println("Starting Solana block scanner for e-voting program...")

	for {
		limit := 50
		opts := &rpc.GetSignaturesForAddressOpts{
			Limit: &limit,
		}
		// If we have a previously processed signature, only fetch newer ones up to that signature
		if !lastProcessedSig.IsZero() {
			opts.Until = lastProcessedSig
		}

		ctx := context.Background()
		sigs, err := client.GetSignaturesForAddressWithOpts(ctx, programID, opts)
		if err != nil {
			log.Printf("Error fetching signatures: %v", err)
			time.Sleep(5 * time.Second)
			continue
		}

		if len(sigs) == 0 {
			time.Sleep(5 * time.Second)
			continue
		}

		// Signatures are returned newest first (descending).
		// We process them from oldest to newest to keep chronological order in case of interruptions.
		for i := len(sigs) - 1; i >= 0; i-- {
			sigInfo := sigs[i]

			if sigInfo.Err != nil {
				// Skip transactions that failed (e.g., duplicated vote error thrown by program)
				lastProcessedSig = sigInfo.Signature
				continue
			}

			processTransaction(ctx, client, db, sigInfo, programID, voteYesSighash, voteNoSighash)
			lastProcessedSig = sigInfo.Signature
		}

		// Slight delay to avoid hitting RPC rate limits continuously
		time.Sleep(3 * time.Second)
	}
}

func startWebServer(db *sql.DB) {
	tmpl := template.Must(template.ParseFiles("templates/index.html"))

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		// Fetch the latest 100 votes
		rows, err := db.Query(`SELECT signature, voter, proposal, vote_type, block_time FROM votes ORDER BY block_time DESC LIMIT 100`)
		if err != nil {
			http.Error(w, "Failed to query database", http.StatusInternalServerError)
			log.Printf("DB Query error: %v", err)
			return
		}
		defer rows.Close()

		var votes []VoteRecord
		for rows.Next() {
			var v VoteRecord
			var bt int64
			if err := rows.Scan(&v.Signature, &v.Voter, &v.Proposal, &v.VoteType, &bt); err != nil {
				log.Printf("Row scan error: %v", err)
				continue
			}

			// Convert Unix timestamp to readable format
			if bt > 0 {
				v.BlockTime = time.Unix(bt, 0).Format("2006-01-02 15:04:05")
			} else {
				v.BlockTime = "Unknown"
			}
			votes = append(votes, v)
		}

		data := PageData{
			Votes: votes,
		}

		if err := tmpl.Execute(w, data); err != nil {
			log.Printf("Template execution error: %v", err)
		}
	})

	log.Println("Web server listening on http://localhost:8080")
	if err := http.ListenAndServe(":8080", nil); err != nil {
		log.Fatalf("Failed to start web server: %v", err)
	}
}

func processTransaction(
	ctx context.Context,
	client *rpc.Client,
	db *sql.DB,
	sigInfo *rpc.TransactionSignature,
	programID solana.PublicKey,
	voteYesSighash, voteNoSighash []byte,
) {
	// Need to support v0 transactions as Phantom and other modern wallets use them
	maxSupportedVersion := uint64(0)
	txInfo, err := client.GetTransaction(
		ctx,
		sigInfo.Signature,
		&rpc.GetTransactionOpts{
			MaxSupportedTransactionVersion: &maxSupportedVersion,
		},
	)
	if err != nil {
		log.Printf("Error fetching transaction %s: %v", sigInfo.Signature, err)
		return
	}

	if txInfo == nil || txInfo.Transaction == nil {
		return
	}

	tx, err := txInfo.Transaction.GetTransaction()
	if err != nil {
		log.Printf("Error parsing transaction %s: %v", sigInfo.Signature, err)
		return
	}

	accountKeys := tx.Message.AccountKeys

	// Loop through top-level instructions inside the transaction
	for _, inst := range tx.Message.Instructions {
		if int(inst.ProgramIDIndex) >= len(accountKeys) {
			continue
		}
		progPubkey := accountKeys[inst.ProgramIDIndex]

		// If instruction doesn't belong to our Anchor program, skip it
		if progPubkey != programID {
			continue
		}

		// Anchor discriminators are exactly 8 bytes long
		if len(inst.Data) >= 8 {
			isYes := bytes.Equal(inst.Data[:8], voteYesSighash)
			isNo := bytes.Equal(inst.Data[:8], voteNoSighash)

			if isYes || isNo {
				voteType := "NO"
				if isYes {
					voteType = "YES"
				}

				// According to the Anchor AddVote Context:
				// inst.Accounts[0] -> proposal
				// inst.Accounts[1] -> user
				// inst.Accounts[2] -> vote
				// inst.Accounts[3] -> system_program
				if len(inst.Accounts) >= 2 {
					proposalIdx := inst.Accounts[0]
					userIdx := inst.Accounts[1]

					if int(proposalIdx) < len(accountKeys) && int(userIdx) < len(accountKeys) {
						proposalPubkey := accountKeys[proposalIdx]
						voterPubkey := accountKeys[userIdx]

						blockTime := int64(0)
						if sigInfo.BlockTime != nil {
							blockTime = int64(*sigInfo.BlockTime)
						}

						saveVote(db, sigInfo.Signature.String(), voterPubkey.String(), proposalPubkey.String(), voteType, blockTime)
					}
				}
			}
		}
	}
}

func saveVote(db *sql.DB, sig, voter, proposal, voteType string, blockTime int64) {
	insertSQL := `INSERT OR IGNORE INTO votes (signature, voter, proposal, vote_type, block_time) VALUES (?, ?, ?, ?, ?)`
	res, err := db.Exec(insertSQL, sig, voter, proposal, voteType, blockTime)

	if err != nil {
		log.Printf("Error saving vote to DB: %v", err)
	} else {
		rows, _ := res.RowsAffected()
		if rows > 0 {
			log.Printf("✓ Saved vote: %s voted %s on %s", voter, voteType, proposal)
		}
	}
}
