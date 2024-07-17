package main

import "fmt"

func main() {
	var quantidade int = 10
	var ponteiro *int = &quantidade

	fmt.Printf("ponteiro: %d\n", ponteiro)
	fmt.Printf("quantidade: %d\n", *ponteiro)
}
