# syntax=docker/dockerfile:1

#	build the application
FROM golang:1.17-alpine AS build

WORKDIR /RestAPI

COPY main.go servidorAPI.go produto.go repositorio.go go.mod go.sum ./

RUN CGO_ENABLED=0 go build -o ./bin/servidorAPI main.go servidorAPI.go produto.go repositorio.go

#	create application image
FROM alpine:latest

WORKDIR /RestAPI

COPY --from=build /RestAPI/bin/servidorAPI ./bin/

EXPOSE 8080
ENTRYPOINT ["/RestAPI/bin/servidorAPI"]
