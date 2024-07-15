package main

import "fmt"

func main() {
	const meta = 200
	var quantidade int = 10
	preco := 25

	if quantidade*preco > meta {
		fmt.Printf("valor total ultrapassou a meta: %d / %d\n", quantidade*preco, meta)
	}
}
