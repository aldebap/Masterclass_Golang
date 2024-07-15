package main

import "fmt"

func main() {
	idade := make(map[string]int)

	idade["Joao"] = 20
	idade["Maria"] = 18

	fmt.Printf("tamanho do map de idades: %d\n", len(idade))
	fmt.Printf("idade de Joao: %d\n", idade["Joao"])
}
