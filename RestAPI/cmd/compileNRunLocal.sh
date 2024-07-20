#!	/usr/bin/ksh

go build -o bin/servidorAPI *.go

export  DATABASEURL=''
export  SERVICEPORT=':8080'

bin/servidorAPI
