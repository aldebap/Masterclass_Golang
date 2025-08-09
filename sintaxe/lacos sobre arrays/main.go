package main

import "fmt"

func main() {
	var quantidade []int = []int{10, 15, 25}
	var sum int

	for i, elem := range quantidade {
		sum += elem
	}

	fmt.Printf("somatorio: %d\n", sum)
}
