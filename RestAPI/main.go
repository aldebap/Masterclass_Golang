package main

import (
	"fmt"
	"log"
)

func main() {

	var servidor ServidorAPI

	fmt.Printf(">>> Servidor API\n\n")

	err := servidor.lerConfig()
	if err != nil {
		log.Fatal(err)
	}

	log.Panic(servidor.iniciar())
}
