import Fluent
import FluentSQLiteDriver
import Vapor
import PureSwiftJSON

// configures your application
public func configure(_ app: Application) throws {
    app.databases.use(.sqlite(.memory), as: .sqlite)
    
    app.migrations.add(CreateTodo())

    try routes(app)
    
    try app.autoMigrate().wait()
}

extension PSJSONEncoder: ContentEncoder {
    public func encode<E: Encodable>(
        _ encodable: E,
        to body: inout ByteBuffer,
        headers: inout HTTPHeaders
    ) throws {
        headers.contentType = .json
        let bytes: [UInt8] = try self.encode(encodable)
        // the buffer's storage is resized in case its capacity is not sufficient
        body.writeBytes(bytes)
    }
}

extension PSJSONDecoder: ContentDecoder {
    public func decode<D: Decodable>(
        _ decodable: D.Type,
        from body: ByteBuffer,
        headers: HTTPHeaders
    ) throws -> D {
        guard headers.contentType == .json || headers.contentType == .jsonAPI else {
            throw Abort(.unsupportedMediaType)
        }
        
        return try self.decode(D.self, from: body.getBytes(at: 0, length: body.readableBytes)!)
    }
}
