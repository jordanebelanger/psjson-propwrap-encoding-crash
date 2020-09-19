@testable import App
import XCTVapor

final class AppTests: XCTestCase {
    func testHelloWorld() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)
        
        // creating a model with Fluent @OptionalField property and saving it to our database (the database type doesnt matter)
        try Todo(id: .init(), title: "Crashing model", optPropWrapVal: "hasValue").create(on: app.db).wait()
        
        // Loading the model and encoding it to json using PSJSONEncoder()
        // This will crash before the test can finish with a "precondition" failure
        try app.test(.GET, "todos", afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
        })
    }
}
