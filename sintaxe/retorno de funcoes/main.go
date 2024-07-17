package main

import "fmt"

func Fatorial(n int) int {
	var fatorial int = 1

	for i := 1; i <= n; i++ {
		fatorial *= i
	}

	return fatorial
}

func main() {
	fmt.Printf("fatorial: %d\n", Fatorial(5))
}
