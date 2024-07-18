package main

import "fmt"

type Serializavel interface {
	ToString() string
}

type Produto struct {
	codigo    int
	descricao string
	preco     float64
}

func (p Produto) ToString() string {
	return fmt.Sprintf("codigo: %d ; descricao: %s ; preco: %8.2f", p.codigo, p.descricao, p.preco)
}

func main() {
	var produto Serializavel = Produto{
		codigo:    10,
		descricao: "teclado",
		preco:     275.0,
	}

	fmt.Printf("produto: %s\n", produto.ToString())
}
