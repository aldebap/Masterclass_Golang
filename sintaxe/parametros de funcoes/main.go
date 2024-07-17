package main

import "fmt"

func Fatorial(n int, f *int) {
	*f = 1

	for i := 1; i <= n; i++ {
		*f *= i
	}
}

func main() {
	var fatorial int

	Fatorial(5, &fatorial)
	fmt.Printf("fatorial: %d\n", fatorial)
}
