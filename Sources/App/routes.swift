import Routing
import Vapor
import Fluent
import Leaf


struct TodoView : Codable {
    var id: Int?
    
    /// A title describing what this `Todo` entails.
    var task: String
    
    var status: Bool
    
    var deadline: String?
    
}

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router) throws {
   
    
    setbuf(stdout, nil)
    // Basic "Hello, world!" example
    router.get("/") { req in
        return "this is the snatch todos service list all todo items use /todos"
    }
    
    let todoController = TodoController()
    router.get("/todos", use: todoController.index)
    router.post("/todos/task/add/", use: todoController.create)
    router.put("/todos/task/check-off", use: todoController.update)
    router.delete("/todos/task/delete/", Todo.parameter, use: todoController.delete)
    
    router.get("/todos/done") { req in
        return req.withNewConnection(to: .psql) { db -> Future<[Todo]> in
            return Todo.query(on: req).filter(\Todo.status == true).all()
        }
    }
    // Add temporally a the web view
    router.get("/alltodos") { req -> Future<View> in
        let renderer = try req.make(LeafRenderer.self)
        let client = try req.make(Client.self)
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("dd.MM.yyyy")
        let res: Future<Response> = client.get("http://localhost:8080/todos")
        // Transforms the `Future<Response>` to `Future<ExampleData>`
        let allTodos = res.flatMap { res -> EventLoopFuture<[TodoView]> in
            return try res.content.decode([TodoView].self)
        }
//        let allTodos = res.map { todos -> Future<TodoView> in
//           print("body: \(todos.content)")
//            print(try todos.content.decode(TodoView.self))
//            let aListOfTodos = try todos.content.decode(TodoView.self)
//            return aListOfTodos
//        }
        let context = ["tasks": allTodos]
        return renderer.render("alltodos",context)
    }
}
