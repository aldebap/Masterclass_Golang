package main

import "fmt"

func main() {
	quantidade := make([]int, 3)

	quantidade[0] = 10
	quantidade[1] = 15
	quantidade = append(quantidade, 40)

	fmt.Printf("tamanho do slice de valores: %d\n", len(quantidade))
	fmt.Printf("slice de valores: %s\n", quantidade)
	fmt.Printf("primeiro trimestre de valores: %s\n", quantidade[0:3])
}
