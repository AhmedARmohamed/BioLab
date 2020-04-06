import Vapor
import Leaf

struct IndexController: RouteCollection {
    func boot(router: Router) throws {
        router.get(use: index)
        router.get("users", User.parameter, use: samples)
    }
    
    func index(_ req: Request) throws -> Future<View> {
        return User.query(on: req)
        .all()
            .flatMap(to: View.self, { userModels in
                let users = userModels.isEmpty ? nil: userModels
                let indexContext = IndexContext(tittle: "Bio Lab", users: users)
                return try req.view().render("index", indexContext)
            })
    }
    
    func samples(_ req: Request) throws -> Future<View> {
        return try req.parameters.next(User.self)
            .flatMap(to: View.self, { user in
                return try user.samples.query(on: req).all()
                    .flatMap(to: View.self, { samples in
                        let sampleContext = SampleContext(tittle: "Samples", samples: samples, user: user)
                        return try req.view().render("sample", sampleContext)
                    })
            })
    }
}

struct IndexContext: Encodable {
    let tittle: String
    let users: [User]?
}

struct SampleContext: Encodable {
    let tittle: String
    let samples: [Sample]
    let user: User
}
