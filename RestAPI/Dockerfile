# syntax=docker/dockerfile:1

#	build the application
FROM golang:1.17-alpine AS build

WORKDIR /personaLib

COPY main.go app.go go.mod go.sum ./
COPY controller/author.go controller/book.go controller/controller.go controller/go.mod controller/publisher.go ./controller/
COPY model/author.go model/book.go model/id.go model/go.mod model/publisher.go ./model/
COPY store/author.go store/book.go store/collection.go store/go.mod store/publisher.go ./store/

RUN CGO_ENABLED=0 go build -o ./bin/server app.go main.go

#	create application image
FROM alpine:latest

WORKDIR /personaLib

COPY --from=build /personaLib/bin/server ./bin/

EXPOSE 8080
ENTRYPOINT ["/personaLib/bin/server"]
