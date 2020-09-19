# psjson-propwrap-encoding-crash
Encoding propertywrapper that wraps optional wrappedValue as JSON with PSJSONEncoder leads to a crash. Do note that while the example here shows a scenario whereas a Fluent Model with
an @OptionalField is encoded in a Response leading to a crash, the crash is generalized to propertyWrappers that wraps optional elements.

I added a Fluent @OptionalField property to the vapor's api template `Todo` model
```swift
final class Todo: Model, Content {
    static let schema = "todos"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "title")
    var title: String
    
    // Encoding this to JSON in a response using `PSJSONEncoder` will crash no matter if the value is set or not
    @OptionalField(key: "opt_prop")
    var optPropWrapVal: String?

    init() { }

    init(id: UUID? = nil, title: String, optPropWrapVal: String?) {
        self.id = id
        self.title = title
    }
}
```
Encoding one of these codable model to json with `PSJSONEncoder` as the Vapor's app JSON `ContentEncoder` leads to a crash (works with the Foundation encoder).
```swift
    func testPSJSONEncoderCrash() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)
        
        // creating a model with Fluent @OptionalField property and saving it to our database (the database type doesnt matter)
        try Todo(id: .init(), title: "Crashing model", optPropWrapVal: "hasValue").create(on: app.db).wait()
        
        // loading the model in a response with `JSONEncoder` works
        try app.test(.GET, "todos", afterResponse: { res in
            try print(res.content.decode(Todo.self))
            XCTAssertEqual(res.status, .ok)
        })
        
        // switching to `PSJSONEncoder` as the ContentEncoder
        ContentConfiguration.global.use(encoder: PSJSONEncoder(), for: .json)
        
        // Loading the model and encoding it to json using PSJSONEncoder()
        // This will crash before the test can finish with a "precondition" failure
        try app.test(.GET, "todos", afterResponse: { res in
            try print(res.content.decode(Todo.self))
            XCTAssertEqual(res.status, .ok)
        })
    }
```

