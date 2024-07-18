package main

import "fmt"

type Produto struct {
	codigo    int
	descricao string
	preco     float64
}

func main() {
	var produto Produto = Produto{
		codigo:    10,
		descricao: "teclado",
		preco:     275.0,
	}

	fmt.Printf("produto: %s\n", produto)
}
