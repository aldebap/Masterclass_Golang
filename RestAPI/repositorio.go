package main

import (
	"context"
	"time"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
)

var collectionProdutos *mongo.Collection

// inicializa a colecao para Produtos
func InicializaCollection(dbClient *mongo.Client) {
	collectionProdutos = dbClient.Database("ImpactaDB").Collection("produtos")
}

type ProdutoDB struct {
	Id        primitive.ObjectID `bson:"_id,omitempty"`
	Codigo    string             `bson:"codigo"`
	Descricao string             `bson:"descricao"`
	Preco     float64            `bson:"preco,omitempty"`
}

func InserirProduto(produto Produto) error {

	var novoProduto ProdutoDB

	novoProduto.Id = primitive.NewObjectID()
	novoProduto.Codigo = produto.Codigo
	novoProduto.Descricao = produto.Descricao
	novoProduto.Preco = produto.Preco

	//	insere o produto na collection
	ctx, _ := context.WithTimeout(context.Background(), 10*time.Second)
	_, err := collectionProdutos.InsertOne(ctx, novoProduto)
	if err != nil {
		return err
	}

	return nil
}

func ConsultarProduto(codigo string) (*Produto, error) {

	//	consulta o produto por codigo na collection
	var produto ProdutoDB

	ctx, _ := context.WithTimeout(context.Background(), 10*time.Second)
	err := collectionProdutos.FindOne(ctx, bson.M{"codigo": codigo}).Decode(&produto)
	if err != nil {
		return nil, err
	}

	return &Produto{
		Codigo:    produto.Codigo,
		Descricao: produto.Descricao,
		Preco:     produto.Preco,
	}, nil
}
