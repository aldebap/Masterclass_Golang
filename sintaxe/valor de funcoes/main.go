package main

import "fmt"

func Quadrado(n int) int { return n * n }
func Cubo(n int) int     { return n * n * n }

func Imprime(n int, nome string, f func(int) int) {
	fmt.Printf("%s(%d): %d\n", nome, n, f(n))
}

func main() {
	Imprime(2, "n^2", Quadrado)
	Imprime(3, "n^3", Cubo)
	Imprime(4, "n^4", func(n int) int {
		return n * n * n * n
	})
}
