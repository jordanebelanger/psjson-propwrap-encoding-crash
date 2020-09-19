@testable import App
import PureSwiftJSON
import XCTVapor

final class AppTests: XCTestCase {
    func testPSJSONEncoderCrash() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)
        
        // creating a model with Fluent @OptionalField property and saving it to our database (the database type doesnt matter)
        try Todo(id: .init(), title: "Crashing model", optPropWrapVal: "hasValue").create(on: app.db).wait()
        
        // loading the model in a response with `JSONEncoder` works
        try app.test(.GET, "todos", afterResponse: { res in
            print("\n\nLoaded the models with Foundation ok, will switch to PSJSONEncoder.")
            try print(res.content.decode([Todo].self))
            print("\n\n")
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
}
