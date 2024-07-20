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
[helloWorld](https://github.com/aldebap/Masterclass_Golang/tree/main/helloWorld).
Para executar esse programa diretamente a partir da linha de comando, utilizar o seguinte:

```sh
go run main.go
```

## Sintaxe de GoLang

A pasta __sintaxe__ contém os programas utilizados para demonstrar os detalhes da sintaxe de GoLang.
Dentro dessa pasta, existe uma sub-pasta para cada aspecto da sintaxe de GoLang tratada no cusso:

- [comentarios](https://github.com/aldebap/Masterclass_Golang/tree/main/sintaxe/comentarios)
- [constantes](https://github.com/aldebap/Masterclass_Golang/tree/main/sintaxe/constantes)
- [variaveis](https://github.com/aldebap/Masterclass_Golang/tree/main/sintaxe/variaveis)
- [arrays](https://github.com/aldebap/Masterclass_Golang/tree/main/sintaxe/arrays)
- [slices](https://github.com/aldebap/Masterclass_Golang/tree/main/sintaxe/slices)
- [maps](https://github.com/aldebap/Masterclass_Golang/tree/main/sintaxe/maps)
- [ponteiros](https://github.com/aldebap/Masterclass_Golang/tree/main/sintaxe/ponteiros)
- [condicoes](https://github.com/aldebap/Masterclass_Golang/tree/main/sintaxe/condicoes)
- [lacos gerais](https://github.com/aldebap/Masterclass_Golang/tree/main/sintaxe/lacos%20gerais)
- [lacos sobre arrays](https://github.com/aldebap/Masterclass_Golang/tree/main/sintaxe/lacos%20sobre%20arrays)
- [lacos sobre maps](https://github.com/aldebap/Masterclass_Golang/tree/main/sintaxe/lacos%20sobre%20maps)
- [funcoes](https://github.com/aldebap/Masterclass_Golang/tree/main/sintaxe/funcoes)
- [parametros de funcoes](https://github.com/aldebap/Masterclass_Golang/tree/main/sintaxe/parametros%20de%20funcoes)
- [retorno de funcoes](https://github.com/aldebap/Masterclass_Golang/tree/main/sintaxe/retorno%20de%20funcoes)
- [valor de funcoes](https://github.com/aldebap/Masterclass_Golang/tree/main/sintaxe/valor%20de%20funcoes)
- [tratamento de erros](https://github.com/aldebap/Masterclass_Golang/tree/main/sintaxe/tratamento%20erros)
- [go functions](https://github.com/aldebap/Masterclass_Golang/tree/main/sintaxe/go%20functions)
- [estruturas](https://github.com/aldebap/Masterclass_Golang/tree/main/sintaxe/estruturas)
- [metodos](https://github.com/aldebap/Masterclass_Golang/tree/main/sintaxe/metodos)
- [interface](https://github.com/aldebap/Masterclass_Golang/tree/main/sintaxe/interface)

## Programa Hello API

Hello API é uma versão REstFul API do programa para imprimir uma mensagem de "Hello World !" e está
disponível na pasta [helloAPI](https://github.com/aldebap/Masterclass_Golang/tree/main/helloAPI).
Para executar esse programa diretamente a partir da linha de comando, utilizar o seguinte:

```sh
go run main.go
```

Como um API é um servidor web, ele escuta requisições na porta 8080, e para ser encerrado é preciso
utilizar o sinal CTRL + C para interromper o servidor.
Na pasta [test](https://github.com/aldebap/Masterclass_Golang/tree/main/test) existe uma coleção
para o [Postman](https://www.postman.com/) que permite testar o Hello API utilizando uma requisição
na pasta __Hello API__ da coleção.

## Rest API

Essa é uma implementação de um API Restful para uma entidade produto, que utiliza os pacotes
externos GorillaMux e o MongoDriver.
Para que o compilador possa resolver fazer os download das dependências dos pacotes utilizados
é necessário executar os seguintes comandos:

```sh
go mod init main
go mod tidy
```

Com isso serão gerados dois arquivos necessários para a compilação do servidor: __go.mod__ e
__go.sum__.
Caso esses arquivos sejam apagados, basta executar novamente os dois comandos acima.

Um script para compilar o servidor para o RestAPI, criar um container para esse servidor e iniciar
uma instância do MongoDB e do servidor usando Docker Compose está disponível na pasta
[cmd](https://github.com/aldebap/Masterclass_Golang/tree/main/RestAPI/cmd), e é executada com o
seguinte comando:

```sh
cmd/packageNRun.sh
```

Para encerrar a execução de ambos os containers basta teclar CTRL + C
