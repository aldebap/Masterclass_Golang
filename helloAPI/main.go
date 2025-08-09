package main

import (
	"log"
	"net/http"
)

func main() {
	http.HandleFunc("/hello", HelloAPI)

	log.Panic(http.ListenAndServe(":8080", nil))
}
