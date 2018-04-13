import FluentPostgreSQL
import Vapor

/// Other services....

/// Called before your application initializes.
///
/// https://docs.vapor.codes/3.0/getting-started/structure/#configureswift
public func configure(
    _ config: inout Config,
    _ env: inout Environment,
    _ services: inout Services
) throws {
    /// Register providers first
    try services.register(FluentPostgreSQLProvider())
    
//    print(ProcessInfo.processInfo.environment.debugDescription)
    // Configure the socket
    var host:String?
    var port:Int?
    if (ProcessInfo.processInfo.environment["HOST"] != nil) {
        host = ProcessInfo.processInfo.environment["HOST"] ?? "0.0.0.0"
    }
    if (ProcessInfo.processInfo.environment["PORT"] != nil) {
        port = Int(ProcessInfo.processInfo.environment["PORT"]!) ?? 8080
    }
    let server = EngineServerConfig.default(hostname: host!, port: port!)
    services.register(server)
    
    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(DateMiddleware.self) // Adds `Date` header to responses
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)
    
    // Configure a PostgreSQL database
    /// Register custom PostgreSQL Config
    var psqlhost:String?
    var psqlport:Int?
    var psqluser:String?
    var psqlpassword:String?
    var psqldatabase:String?
    if (ProcessInfo.processInfo.environment["PSQLHOSTNAME"] != nil) {
        psqlhost = ProcessInfo.processInfo.environment["PSQLHOSTNAME"] ?? "localhost"
    }
    if (ProcessInfo.processInfo.environment["PSQLPORT"] != nil) {
        psqlport = Int(ProcessInfo.processInfo.environment["PSQLPORT"]!) ?? 5432
    }
    if (ProcessInfo.processInfo.environment["PSQLUSERNAME"] != nil) {
        psqluser = ProcessInfo.processInfo.environment["PSQLUSERNAME"] ?? "unknown"
    }
    if (ProcessInfo.processInfo.environment["PSQLPASSWORD"] != nil) {
        psqlpassword = ProcessInfo.processInfo.environment["PSQLPASSWORD"] ?? "unknown"
    }
    if (ProcessInfo.processInfo.environment["PSQLDATABASE"] != nil) {
        psqldatabase = ProcessInfo.processInfo.environment["PSQLDATABASE"] ?? "unknown"
    }
    let psqlConfig = PostgreSQLDatabaseConfig(hostname: psqlhost!,
                                              port: psqlport!,
                                              username: psqluser! ,
                                              database: psqldatabase!,
                                              password: psqlpassword!
                                             )
//    services.register(psqlConfig)
    let psql = PostgreSQLDatabase(config: psqlConfig)
    var databases = DatabaseConfig()
    databases.add(database: psql, as: .psql)
    services.register(databases)
    
    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: Todo.self, database: .psql)
    services.register(migrations)
}
