package main

import "fmt"

func Fatorial(n int) {
	var fatorial int = 1

	for i := 1; i <= n; i++ {
		fatorial *= i
	}

	fmt.Printf("fatorial: %d\n", fatorial)
}

func main() {
	go Fatorial(5)

	for i := 1; i <= 100; i++ {
		fmt.Printf("i = %d\n", i)
	}
}
