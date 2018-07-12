import Vapor

/// Controlers basic CRUD operations on `Todo`s.
final class TodoController {
    
    let dateFormatter = DateFormatter()
    
    init(){
        dateFormatter.locale = Locale(identifier: "de_DE")
        dateFormatter.setLocalizedDateFormatFromTemplate("dd.MM.yyyy")
    }

    /// Returns a list of all `Todo`s.
    func index(_ req: Request) throws -> Future<[Todo]> {
        let query = Todo.query(on: req)
        let result = query.all()
        print(result)
        return result
    }

    /// Saves a decoded `Todo` to the database.
    func create(_ req: Request) throws -> Future<Todo> {
        return try req.content.decode(json: Todo.self, using: .custom(dates: JSONDecoder.DateDecodingStrategy.formatted(dateFormatter))).flatMap(to: Todo.self) { todo in
            return todo.save(on: req)
        }
    }
    /// Updates a decoded `Todo` to the database.
    func update(_ req: Request) throws -> Future<Todo> {
        return try req.content.decode(json: Todo.self, using: .custom(dates: JSONDecoder.DateDecodingStrategy.formatted(dateFormatter))).flatMap(to: Todo.self) { todo in
            return todo.update(on: req)
        }
    }

    /// Deletes a parameterized `Todo`.
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Todo.self).flatMap(to: Void.self) { todo in
            return todo.delete(on: req)
        }.transform(to: .ok)
    }
    
}
