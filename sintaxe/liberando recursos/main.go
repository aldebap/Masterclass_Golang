package main

import (
	"bufio"
	"fmt"
	"os"
)

func main() {
	//	abre um arquivo text
	arquivo, err := os.Open("recursos.txt")
	if err != nil {
		fmt.Fprintf(os.Stderr, "erro abrindo o arquivo: "+err.Error()+"\n")
		os.Exit(-1)
	}
	defer arquivo.Close()

	scanner := bufio.NewScanner(arquivo)
	for scanner.Scan() {
		fmt.Println(scanner.Text())
	}
}
