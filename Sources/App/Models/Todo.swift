import Fluent
import Vapor

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
