package main

import "fmt"

func main() {
	idade := make(map[string]int)
	fmt.Printf("tamanho inicial do map de idades: %d\n", len(idade))

	idade["Joao"] = 20
	idade["Maria"] = 18

	//	idade["Joao"] = 25

	fmt.Printf("tamanho do map de idades: %d\n", len(idade))
	fmt.Printf("idade de Joao: %d\n", idade["Joao"])
}
