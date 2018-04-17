# Snatch Todo Backend  

## Goal
This example "*todo backend*" should help me to demo the **swift runtime** for cloud foundry. I would like show the latest stuff for swift, that's the reason why I choose **vapor 3** with **swift NIO**. 

## Run it on your local machine
### Prerequisite
Get it on your local machine and build it.
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

**Local setup**

```shell
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
Run it
```shell
bash$ .build/x86_64-apple-macosx10.10/debug/Run
[ INFO ] Migrating 'psql' database (FluentProvider.swift:28)
[ INFO ] Migrations complete (FluentProvider.swift:32)
Server starting on http://0.0.0.0:8080
```

## How it works

### Api calls

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
Example call to create a new task on the todo list
```
curl -X POST  http://localhost:8080/todos/task/add -d '{ "task" : "your todo task", "status": false }' -H 'Content-Type: application/json'
```
Response
```
{"id":3,"task":"your todo task","status":false}

```

/todos/task/check-off  
Payload
```json
{
  "id":1,
  "task":"my first todo",
  "status":true
}
````

Example call to check-off a task on the todo list
```
curl -X PUT  http://localhost:8080/todos/task/check-off -d '{"id":1,"task":"my first todo","status":true}' -H 'Content-Type: application/json'
```

Response
```
{"id":1,"task":"my first todo","status":true}
```

/todos/task/delete/:id

Example call to delete a task from the todo list
```
curl -iv -X DELETE  http://localhost:8080/todos/task/delete/4
```

Response
```
HTTP 200
```

## Cloud Foundry setup

### Prerequisite
You need a Postgres Database accessible from anywhere. (e.q. https://console.bluemix.net/catalog/services/elephantsql or your own). And be sure that you are connected to your cloud foundry provider, I have used IBM Cloud Foundry.
Then provide the credentials to the cf runtime as environment variables with `cf set-env`, in my case it is for `snatch-todo` environment.

```
cf set-env snatch-todos PSQLHOSTNAME "packy.db.elephantsql.com"
cf set-env snatch-todos PSQLPORT 5432
cf set-env snatch-todos PSQLUSERNAME "xxxxx"
cf set-env snatch-todos PSQLDATABASE "xxxxx"
cf set-env snatch-todos PSQLPASSWORD "*****"
```
### Deploy in cf

This is the custom command to deploy vapor 3 to cloudfoundry, the build pack is necessary, because we need definitely swift 4.1! 
!! Be sure that you are connected to your cloud foundry 

```shell
cf push snatch-todos 32M -c Run -b https://github.com/IBM-Swift/swift-buildpack/releases/download/2.0.11/buildpack_swift_v2.0.11-20180402-2018.zip
```

Verify after the deploy (I had deployed in london)
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
