
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
}
