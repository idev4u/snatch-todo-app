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
    let host = ProcessInfo.processInfo.environment["VCAP_APP_HOST"] ?? "0.0.0.0"
    let port = ProcessInfo.processInfo.environment["PORT"] ?? "8080"
    
    let server = NIOServerConfig.default(hostname: host, port: Int(port)!)
    services.register(server)
    
    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
//    middlewares.use(DateMiddleware.self) // Adds `Date` header to responses
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)
    
    // Configure a PostgreSQL database
    /// Register custom PostgreSQL Config
 
    let psqlhost = ProcessInfo.processInfo.environment["PSQLHOSTNAME"] ?? "localhost"
    var psqlport:Int?
    if (ProcessInfo.processInfo.environment["PSQLPORT"] != nil) {
        psqlport = Int(ProcessInfo.processInfo.environment["PSQLPORT"]!)
    } else {
        psqlport = 5432
    }
    let psqluser = ProcessInfo.processInfo.environment["PSQLUSERNAME"] ?? "unknown"
    let psqlpassword = ProcessInfo.processInfo.environment["PSQLPASSWORD"] ?? "unknown"
    let psqldatabase = ProcessInfo.processInfo.environment["PSQLDATABASE"] ?? "unknown"
    let psqlConfig = PostgreSQLDatabaseConfig(hostname: psqlhost,
                                              port: psqlport!,
                                              username: psqluser ,
                                              database: psqldatabase,
                                              password: psqlpassword
                                             )

//    services.register(psqlConfig)
    let psql = PostgreSQLDatabase(config: psqlConfig)
    var databases = DatabasesConfig()
    databases.add(database: psql, as: .psql)
    services.register(databases)
    
    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: Todo.self, database: .psql)
    services.register(migrations)
}
