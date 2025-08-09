package main

import "fmt"

func main() {
	var quantidade [3]int

	quantidade[0] = 10
	quantidade[1] = 15
	i := 3
	quantidade[i] = 25

	fmt.Printf("tamanho do array de valores: %d\n", len(quantidade))
	fmt.Printf("array de valores: %s\n", quantidade)
}
