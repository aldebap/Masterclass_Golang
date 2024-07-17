# Masterclass Golang

Esse repo contém o material de apoio para o curso Masterclass GoLang (Impacta)

## Instalação das Ferramentas

Para instalar o compilador e ferramentas do GoLang, basta fazer o download da versão apropriada ao
seu sistema operacional no seguinte caminho: [Download GoLang](https://go.dev/dl/)

Caso utilize o VSC, é recomendável instalar a seguinte extenção: __Go for Visual Studio Code__
Essa extensão recursos de ênfase para a sintaxe, auto-complete para o código, preenchimento
automático dos pacotes de dependências, navegação fácil por todo o código, diagnóstico, sugestões,
debug e testes.

## Programa Hello World

O tradicional programa para imprimir uma mensagem de "Hello World !" está disponível na pasta
__helloWorld__.
Para executar esse programa diretamente a partir da linha de comando, utilizar o seguinte:

```sh
go run main.go
```

## Sintaxe de GoLang

A pasta __sintaxe__ contém os programas utilizados para demonstrar os detalhes da sintaxe de GoLang.
Dentro dessa pasta, existe uma sub-pasta para cada aspecto da sintaxe de GoLang tratada no cusso:

- comentarios
- constantes
- variaveis
- arrays
- slices
- maps
- ponteiros
- condicoes
- lacos gerais
- lacos sobre arrays
- lacos sobre maps
- funcoes
- parametros de funcoes
- retorno de funcoes
- TODO
- tratamento de erros
- go functions
- TODO

## Programa Hello API

Hello API é uma versão REstFul API do programa para imprimir uma mensagem de "Hello World !" e está
disponível na pasta __helloAPI__.
Para executar esse programa diretamente a partir da linha de comando, utilizar o seguinte:

```sh
go run main.go
```

Como um API é um servidor web, ele escuta requisições na porta 8080, e para ser encerrado é preciso
utilizar o sinal CTRL + C para interromper o servidor.
Na pasta __test__ existe uma coleção para o [Postman](https://www.postman.com/) que permite testar o
Hello API utilizando uma requisição na pasta __Hello API__ da coleção.
