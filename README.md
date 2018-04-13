# TODO App Vapor 3

Goal this should help me to demo cloud foundry swift runtime on the IBM Cloud meetup.

## run on your machine
### prerequisite
get it on your local machine and build it.
```shell
bash$ git  clone ...
bash$ cd snatch-todo-app
bash$ swift build
```

**local setup**

```shell
# Postgresql Setup
export PSQLHOSTNAME="packy.db.elephantsql.com"
export PSQLPORT=5432
export PSQLUSERNAME="xxxxx"
export PSQLDATABASE="xxxxx"
export PSQLPASSWORD="******"
#Server Setup
export HOST="0.0.0.0"
export PORT=8080
```
run it
```shell
bash$ .build/x86_64-apple-macosx10.10/debug/Run
[ INFO ] Migrating 'psql' database (FluentProvider.swift:28)
[ INFO ] Migrations complete (FluentProvider.swift:32)
Server starting on http://0.0.0.0:8080
```

## how it works

### api calls

Add a todo task

/todos/task/add
payload
```json
{
  "id":1,
  "task":"my first todo",
  "status":false
}
````
example call
```
curl -X POST  http://localhost:8080/todos/task/add -d '{ "task" : "your todo task", "status": false }' -H 'Content-Type: application/json'
```
Response
```
{"id":3,"task":"your todo task","status":false}

```

/todos/task/check-off
payload
```json
{
  "id":1,
  "task":"my first todo",
  "status":true
}
````

example call
```
curl -X PUT  http://localhost:8080/todos/task/check-off -d '{"id":1,"task":"my first todo","status":true}' -H 'Content-Type: application/json'
```

Response
```
{"id":1,"task":"my first todo","status":true}
```

/todos/task/delete/:id
```
curl -iv -X DELETE  http://localhost:8080/todos/task/delete/4
```

Response
```
HTTP 200
```

## cf setup

```
cf set-env snatch-todos PSQLHOSTNAME "packy.db.elephantsql.com"
cf set-env snatch-todos PSQLPORT 5432
cf set-env snatch-todos PSQLUSERNAME "xxxxx"
cf set-env snatch-todos PSQLDATABASE "xxxxx"
cf set-env snatch-todos PSQLPASSWORD "*****"
```
deploy in cf

this is the custom command to deploy vapor 3 to cloudfoundry, the build pack is necessary, because we need defently swift 4.1!

```shell
cf push snatch-todos 32M -c Run -b https://github.com/IBM-Swift/swift-buildpack/releases/download/2.0.11/buildpack_swift_v2.0.11-20180402-2018.zip
```


verify after the deploy (I had deployed in london)
```shell
    curl snatch-todos.eu-gb.mybluemix.net/todos

    curl -X POST  http://snatch-todos.eu-gb.mybluemix.net/todos/task/add -d '{ "task" : "your todo task", "status": false }' -H 'Content-Type: application/json'

    curl -X PUT  http://snatch-todos.eu-gb.mybluemix.net/todos/task/check-off -d '{"id":1,"task":"my first todo","status":true}' -H 'Content-Type: application/json'

    curl -iv -X DELETE  http://snatch-todos.eu-gb.mybluemix.net/todos/task/delete/4
```
