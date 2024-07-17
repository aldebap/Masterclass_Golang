package main

import (
	"errors"
	"fmt"
	"os"
)

func Fatorial(n int) (int, error) {
	var fatorial int = 1

	if n < 0 {
		return 0, errors.New("nao existe fatorial de numeros negativos")
	}

	for i := 1; i <= n; i++ {
		fatorial *= i
	}

	return fatorial, nil
}

func main() {

	fatorial, err := Fatorial(5)
	if err != nil {
		fmt.Fprintf(os.Stderr, "[erro] %s\n", err.Error())
	}
	fmt.Printf("fatorial: %d\n", fatorial)
}
