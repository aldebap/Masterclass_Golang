package main

import (
	"encoding/json"
	"net/http"

	"github.com/gorilla/mux"
)

type Produto struct {
	Codigo    string  `json:"codigo"`
	Descricao string  `json:"descricao"`
	Preco     float64 `json:"preco,omitempty"`
}

func EndpointInserirProduto(httpResponse http.ResponseWriter, httpRequest *http.Request) {

	//	valida se o payload é um "json" (content type)
	contentType := httpRequest.Header.Get("Content-type")
	if contentType != "application/json" {
		httpResponse.WriteHeader(http.StatusUnsupportedMediaType)
		return
	}

	//	 decodifica payload
	var produtoReq Produto

	err := json.NewDecoder(httpRequest.Body).Decode(&produtoReq)
	if nil != err {
		httpResponse.WriteHeader(http.StatusBadRequest)
		return
	}

	//	insere o produto no repositorio
	err = InserirProduto(produtoReq)
	if nil != err {
		httpResponse.WriteHeader(http.StatusInternalServerError)
		return
	}

	//	monta o payload de resposta
	var produtoResp = Produto{}

	produtoResp.Codigo = produtoReq.Codigo
	produtoResp.Descricao = produtoReq.Descricao
	produtoResp.Preco = produtoReq.Preco

	httpResponse.Header().Add("Content-Type", "application/json")
	httpResponse.WriteHeader(http.StatusCreated)
	json.NewEncoder(httpResponse).Encode(produtoResp)
}

func EndpointConsultarProduto(httpResponse http.ResponseWriter, httpRequest *http.Request) {

	//	recupera as variaveis de caminho da requisição
	vars := mux.Vars(httpRequest)
	codigo := vars["codigo"]

	//	consulta o produto no repositorio
	var produto *Produto

	produto, err := ConsultarProduto(codigo)
	if err != nil {
		httpResponse.WriteHeader(http.StatusNotFound)
		return
	}

	//	monta o payload de resposta
	var produtoResp = Produto{}

	produtoResp.Codigo = produto.Codigo
	produtoResp.Descricao = produto.Descricao
	produtoResp.Preco = produto.Preco

	httpResponse.Header().Add("Content-Type", "application/json")
	httpResponse.WriteHeader(http.StatusOK)
	json.NewEncoder(httpResponse).Encode(produtoResp)
}
