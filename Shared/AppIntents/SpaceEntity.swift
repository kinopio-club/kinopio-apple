import AppIntents
import CoreSpotlight

struct SpaceEntity: AppEntity {
    
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Space")
    static var defaultQuery = SpaceEntityQuery()
    
    var id: String
    var name: String
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(name)",
            image: .init(systemName: "heart.fill")
        )
    }
    
    var webURL: URL {
        Configuration.hostURL.appending(path: id)
    }
    
    struct SpaceEntityQuery: EntityStringQuery {
        func entities(matching string: String) async throws -> [SpaceEntity] {
            guard let token = Storage.getToken() else {
                return []
            }
            
            let spaces = try await Networking.getUserSpaces(token: token)
            return spaces
                .filter { $0.name.localizedCaseInsensitiveContains(string) }
                .map { space in
                    SpaceEntity(id: space.id, name: space.name)
                }
        }
        
        func entities(for identifiers: [SpaceEntity.ID]) async throws -> [SpaceEntity] {
            guard let token = Storage.getToken() else {
                return []
            }
            
            let spaces = try await Networking.getUserSpaces(token: token)
            return identifiers.flatMap { identifier in
                spaces
                    .filter { $0.id == identifier }
                    .map { space in
                        SpaceEntity(id: space.id, name: space.name)
                    }
            }
        }
        
        func suggestedEntities() async throws -> [SpaceEntity] {
            guard let token = Storage.getToken() else {
                return []
            }
            
            let spaces = try await Networking.getUserSpaces(token: token)
            return spaces
                .map { space in
                    SpaceEntity(id: space.id, name: space.name)
                }
        }
    }
    
}

@available(iOS 18, *)
extension SpaceEntity: URLRepresentableEntity {
    
    static var urlRepresentation: URLRepresentation {
        "https://kinopio.club/\(.id)"
    }
    
}


@available(iOS 18, *)
extension SpaceEntity: IndexedEntity {
    
    var attributeSet: CSSearchableItemAttributeSet {
        let attributes = CSSearchableItemAttributeSet()
        
        attributes.title = name
        attributes.displayName = name
        
        return attributes
    }
    
}
