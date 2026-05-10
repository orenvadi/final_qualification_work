package main
import (
	"context"
	"fmt"
	"github.com/gagliardetto/solana-go/rpc"
	"github.com/gagliardetto/solana-go"
)
func main() {
	client := rpc.New(rpc.DevNet_RPC)
	sig := solana.MustSignatureFromBase58("5XQk3G4r7Hq1E3eM7JzM5Fm3k8KxJ3bT3F4K3g2rT8eK1Q6M9JzM5Fm3k8KxJ3bT3F4K3g2rT8eK1Q6M")
	// dummy, I just want to compile it and see if the methods exist.
	_, _ = client.GetTransaction(context.Background(), sig, &rpc.GetTransactionOpts{})
}
