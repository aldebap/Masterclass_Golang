////////////////////////////////////////////////////////////////////////////////
//	app.go  -  Feb/10/2022  -  aldebap
//
//	personLib App
////////////////////////////////////////////////////////////////////////////////

package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/gorilla/mux"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"

	"personaLib/controller"
	"personaLib/store"
)

type Config struct {
	databaseURL string
	timeout     time.Duration
	servicePort string
}

type App struct {
	config     *Config
	dbClient   *mongo.Client
	httpRouter *mux.Router
}

//	load the App configuration from environment variables
func GetFromEnv() (*Config, error) {

	//	get configuration parameters from environment
	databaseURL := os.Getenv("DATABASEURL")
	servicePort := os.Getenv("SERVICEPORT")

	//	TODO: validate all required variables
	if len(servicePort) == 0 {
		servicePort = ":8080"
	} else if servicePort[0] != ':' {
		servicePort = ":" + servicePort
	}

	return &Config{
		databaseURL: databaseURL,
		timeout:     10 * time.Second,
		servicePort: servicePort,
	}, nil
}

//	run the application
func (a *App) Run() {
	//	connect to the database
	var err error

	clientOptions := options.Client().ApplyURI(a.config.databaseURL)
	ctx, cancel := context.WithTimeout(context.Background(), a.config.timeout)

	defer cancel()

	a.dbClient, err = mongo.Connect(ctx, clientOptions)
	if err != nil {
		log.Fatal(err)
	}

	defer a.dbClient.Disconnect(ctx)

	//	initialize entities collections
	store.InitCollections(a.dbClient)

	//	start the Web Server
	a.httpRouter = mux.NewRouter()

	a.httpRouter.HandleFunc("/author", controller.AddAuthor).Methods(http.MethodPost)
	a.httpRouter.HandleFunc("/author/{id}", controller.GetAuthor).Methods(http.MethodGet)
	a.httpRouter.HandleFunc("/author", controller.GetAllAuthors).Methods(http.MethodGet)
	a.httpRouter.HandleFunc("/author/{id}", controller.PatchAuthor).Methods(http.MethodPatch)
	a.httpRouter.HandleFunc("/author/{id}", controller.DeleteAuthor).Methods(http.MethodDelete)

	a.httpRouter.HandleFunc("/publisher", controller.AddPublisher).Methods(http.MethodPost)
	a.httpRouter.HandleFunc("/publisher/{id}", controller.GetPublisher).Methods(http.MethodGet)
	a.httpRouter.HandleFunc("/publisher", controller.GetAllPublishers).Methods(http.MethodGet)
	a.httpRouter.HandleFunc("/publisher/{id}", controller.PatchPublisher).Methods(http.MethodPatch)
	a.httpRouter.HandleFunc("/publisher/{id}", controller.DeletePublisher).Methods(http.MethodDelete)

	a.httpRouter.HandleFunc("/book", controller.AddBook).Methods(http.MethodPost)
	a.httpRouter.HandleFunc("/book/{id}", controller.GetBook).Methods(http.MethodGet)
	a.httpRouter.HandleFunc("/book", controller.GetAllBooks).Methods(http.MethodGet)
	a.httpRouter.HandleFunc("/book/{id}", controller.PatchBook).Methods(http.MethodPatch)
	a.httpRouter.HandleFunc("/book/{id}", controller.DeleteBook).Methods(http.MethodDelete)

	http.Handle("/", a.httpRouter)

	//start and listen to requests
	fmt.Printf("Listening port %s\n", a.config.servicePort)

	log.Panic(http.ListenAndServe(a.config.servicePort, a.httpRouter))
}
