
import Routing
import Vapor

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router) throws {
    // Basic "Hello, world!" example
    router.get("/") { req in
        return "this is the snatch todos service list all todo items use /todos"
    }
    router.get("/todos") { req in
        return Todo.query(on: req).all()
    }
    let todoController = TodoController()
    router.post("/todos/task/add/", use: todoController.create)
    router.put("/todos/task/check-off", use: todoController.update)
    router.delete("/todos/task/delete/", Todo.parameter, use: todoController.delete)
    
    router.get("/todos/taks/list/open") { req -> Future<String> in
        return req.withPooledConnection(to: .psql) { conn in
            return conn.query("select task from todos where status = false;").map(to: String.self) { rows in
                let logger = try req.make(Logger.self)
                logger.info("Logger created!")
                var result = [String]()
                for row in rows {
                    logger.info("\(row)")
                    result.append(try row.firstValue(forColumn: "task")?.decode(String.self) ?? "n/a")
                }
                return result.description
            }
        }
    }
    
    router.get("psql-version") { req -> Future<String> in
        return req.withPooledConnection(to: .psql) { conn in
            return conn.query("select version() as v;").map(to: String.self) { rows in
                return try rows[0].firstValue(forColumn: "v")?.decode(String.self) ?? "n/a"
            }
        }
    }
}

