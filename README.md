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
  "task":"my first todo",
  "status":false
  "deadline":"31.10.2020"
}
```
Example call to create a new task on the todo list
```
bash$ curl -X POST  http://localhost:8080/todos/task/add -d '{ "task":"your todo task", "status":false, "deadline":"31.10.2020" }' -H 'Content-Type: application/json'
```
Response
```
{"id":3,"task":"your todo task","status":false,"deadline":"2020-10-30T23:00:00Z"}
```

/todos/task/check-off
Payload
```json
{
  "id":1,
  "task":"my first todo",
  "status":true
  "deadline":"31.10.2020"
}
```

Example call to check-off a task on the todo list
```
bash$ curl -X PUT  http://localhost:8080/todos/task/check-off -d '{"id":1, "task":"my first todo","status":true,"deadline": "31.10.2020"}' -H 'Content-Type: application/json'
```

Response
```
{"id":1,"task":"my first todo","status":true,"deadline":"2020-10-30T23:00:00Z"}
```

/todos/task/delete/:id

Example call to delete a task from the todo list
```
bash$ curl -iv -X DELETE  http://localhost:8080/todos/task/delete/4
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
bash$ cf set-env snatch-todos PSQLHOSTNAME "packy.db.elephantsql.com"
bash$ cf set-env snatch-todos PSQLPORT 5432
bash$ cf set-env snatch-todos PSQLUSERNAME "xxxxx"
bash$ cf set-env snatch-todos PSQLDATABASE "xxxxx"
bash$ cf set-env snatch-todos PSQLPASSWORD "*****"
```
### Deploy in cf

This is the custom command to deploy vapor 3 to cloudfoundry
!! Be sure that you are connected to your cloud foundry.

```shell
bash$ cf push snatch-todos 32M -c Run
```

Verify after the deploy (I had deployed in london)
```shell
bash$ curl -iv snatch-todos.eu-gb.mybluemix.net/todos
```
```shell
bash$ curl -iv -X POST  http://snatch-todos.eu-gb.mybluemix.net/todos/task/add \
-d '{ "task" : "your todo task", "status": false }' \
-H 'Content-Type: application/json'
```
```shell
bash$ curl -iv -X PUT  http://snatch-todos.eu-gb.mybluemix.net/todos/task/check-off \
-d '{"id":1,"task":"my first todo","status":true }' \
-H 'Content-Type: application/json'
```
```shell
bash$ curl -iv -X DELETE  http://snatch-todos.eu-gb.mybluemix.net/todos/task/delete/11
```

## Troubleshooting db

### Restore
Issue:
if you import some test data with squence id which is bigger then the current one, you get a error 'duplicate key'

Solution:

change the sequence min value or start value

```
ALTER SEQUENCE "Todo_id_seq" RESTART WITH 15;
```

get the current min value
```
SELECT max(id)+1 FROM "public"."Todo"
```
