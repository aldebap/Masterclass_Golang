package main

import "fmt"

func fatorial(n int) int {
	var fatorial int = 1

	for i := 1; i <= n; i++ {
		fatorial *= i
	}

	return fatorial
}

func main() {
	fmt.Printf("fatorial: %d\n", fatorial(5))
}
