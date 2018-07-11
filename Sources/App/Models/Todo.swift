import FluentPostgreSQL
import Vapor

/// A single entry of a Todo list.
final class Todo: PostgreSQLModel {
    /// The unique identifier for this `Todo`.
    var id: Int?

    /// A title describing what this `Todo` entails.
    var task: String
    
    var status: Bool
    
    var deadline: Date?

    /// Creates a new `Todo`.
    init(id: Int? = nil, task: String, status: Bool) {
        self.id = id
        self.task = task
        self.status = status
    }
}

/// Allows `Todo` to be used as a dynamic migration.
extension Todo: Migration { }

/// Allows `Todo` to be encoded to and decoded from HTTP messages.
extension Todo: Content { }

/// Allows `Todo` to be used as a dynamic parameter in route definitions.
extension Todo: Parameter {

}
