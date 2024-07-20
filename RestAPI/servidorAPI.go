package main

import (
	"context"
	"fmt"
	"net/http"
	"os"
	"time"

	"github.com/gorilla/mux"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

type ServidorAPI struct {
	databaseURL string
	timeout     time.Duration
	porta       string
	dbClient    *mongo.Client
	httpRouter  *mux.Router
}

func (a *ServidorAPI) lerConfig() error {

	//	le a configuracao das variaveis de ambiente
	a.databaseURL = os.Getenv("DATABASEURL")
	a.porta = os.Getenv("SERVICEPORT")

	if len(a.porta) == 0 {
		a.porta = ":8080"
	} else if a.porta[0] != ':' {
		a.porta = ":" + a.porta
	}

	return nil
}

func (a *ServidorAPI) iniciar() error {

	//	estabelece conexao com o MongoDB
	var err error

	clientOptions := options.Client().ApplyURI(a.databaseURL)
	ctx, cancel := context.WithTimeout(context.Background(), a.timeout)

	defer cancel()

	a.dbClient, err = mongo.Connect(ctx, clientOptions)
	if err != nil {
		return err
	}

	defer a.dbClient.Disconnect(ctx)

	InicializaCollection(a.dbClient)

	//	adicionar as rotas
	a.httpRouter = mux.NewRouter()

	a.httpRouter.HandleFunc("/produtos", EndpointInserirProduto).Methods(http.MethodPost)
	a.httpRouter.HandleFunc("/produtos/{codigo}", EndpointConsultarProduto).Methods(http.MethodGet)

	http.Handle("/", a.httpRouter)

	//	iniciar o servidor
	fmt.Printf("escutando conexoes na porta %s\n", a.porta)

	return http.ListenAndServe(a.porta, a.httpRouter)
}
