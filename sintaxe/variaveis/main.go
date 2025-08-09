package main

import "fmt"

func main() {
	var quantidade uint16 = 10
	preco := (uint16)(25)

	quantidade = quantidade + 5

	fmt.Printf("valor total: %0d\n", quantidade*preco)
}
