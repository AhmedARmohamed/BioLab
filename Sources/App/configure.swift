import FluentMySQL
import Vapor
import Leaf

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // Register providers first
    try services.register(FluentMySQLProvider())
    try services.register(LeafProvider())
    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    // middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)



    // Register the configured SQLite database to the database config.
    var databases = DatabasesConfig()
    let databaseConfig = MySQLDatabaseConfig(hostname: "Localhost", username: "vapor", password: "password", database: "vapor")
    let database = MySQLDatabase(config: databaseConfig)
    databases.add(database: database, as: .mysql)
    services.register(databases)

    // Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: User.self, database: DatabaseIdentifier<User.Database>.mysql)
    migrations.add(model: Sample.self, database: DatabaseIdentifier<Sample.Database>.mysql)
    services.register(migrations)
    
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)
}
