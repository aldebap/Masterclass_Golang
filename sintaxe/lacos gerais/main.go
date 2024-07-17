package main

import "fmt"

func main() {
	var fatorial int = 1

	for i := 1; i <= 5; i++ {
		fatorial *= i
	}

	fmt.Printf("fatorial: %d\n", fatorial)
}
