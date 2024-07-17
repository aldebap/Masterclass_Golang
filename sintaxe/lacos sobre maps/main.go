package main

import "fmt"

func main() {
	var idade map[string]int = map[string]int{
		"Joao":  20,
		"Maria": 18,
	}

	for nome, idade := range idade {
		fmt.Printf("idade de %s: %d\n", nome, idade)
	}
}
