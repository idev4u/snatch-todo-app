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
you need a running psql with this settings in your `pg_hba.conf`config file.

```
# "local" is for Unix domain socket connections only
local   all             all                                     password
# IPv4 local connections:
host    all             all             127.0.0.1/32            password
host    all             all             0.0.0.0/0               password
# IPv6 local connections:
host    all             all             ::1/128                 password
```

**local setup**

```shell
# Postgresql Setup
# Postgresql Setup
export PSQLHOSTNAME="localhost"
export PSQLPORT=5432
export PSQLUSERNAME="turkish"
export PSQLDATABASE="turkish"
export PSQLPASSWORD="******"
#Server Setup
export VCAP_APP_HOST="0.0.0.0"
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

### prerequisite
you need a Postgres DB accessible from anywhere. (e.q. https://console.bluemix.net/catalog/services/elephantsql) or your own.
Then provide the credentials as environment variables for your app, in my case it is for `snatch-todo`

```
cf set-env snatch-todos PSQLHOSTNAME "packy.db.elephantsql.com"
cf set-env snatch-todos PSQLPORT 5432
cf set-env snatch-todos PSQLUSERNAME "xxxxx"
cf set-env snatch-todos PSQLDATABASE "xxxxx"
cf set-env snatch-todos PSQLPASSWORD "*****"
```
deploy in cf

this is the custom command to deploy vapor 3 to cloudfoundry, the build pack is necessary, because we need definitely swift 4.1! 

```shell
cf push snatch-todos 32M -c Run -b https://github.com/IBM-Swift/swift-buildpack/releases/download/2.0.11/buildpack_swift_v2.0.11-20180402-2018.zip
```

verify after the deploy (I had deployed in london)
```shell
    curl -iv snatch-todos.eu-gb.mybluemix.net/todos

    curl -iv -X POST  http://snatch-todos.eu-gb.mybluemix.net/todos/task/add \
    -d '{ "task" : "your todo task", "status": false }' \
    -H 'Content-Type: application/json'

    curl -iv -X PUT  http://snatch-todos.eu-gb.mybluemix.net/todos/task/check-off \
    -d '{"id":1,"task":"my first todo","status":true}' \
    -H 'Content-Type: application/json'

    curl -iv -X DELETE  http://snatch-todos.eu-gb.mybluemix.net/todos/task/delete/11
```
