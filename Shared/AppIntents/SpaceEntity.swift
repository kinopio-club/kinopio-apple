import AppIntents
import CoreSpotlight

struct SpaceEntity: AppEntity {
    
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Space")
    static var defaultQuery = SpaceEntityQuery()
    
    var id: String
    var name: String
    var thumbnailURL: URL?
    var editedAt: Date?
    var createdAt: Date
    
    var displayRepresentation: DisplayRepresentation {
        if let thumbnailURL {
            DisplayRepresentation(
                title: "\(name)",
                subtitle: "Kinopio Space",
                image: .init(url: thumbnailURL)
            )
        } else {
            DisplayRepresentation(
                title: "\(name)",
            )
        }
    }
    
    var webURL: URL {
        Configuration.hostURL.appending(path: id)
    }
    
    struct SpaceEntityQuery: EntityStringQuery {
        
        func entitiesFrom(
            spaces: [Space],
            sortedBy: ((SpaceEntity, SpaceEntity) -> Bool)? = nil
        ) async -> [SpaceEntity] {
            await withTaskGroup { group in
                var entities = [SpaceEntity]()
                
                for space in spaces {
                    group.addTask {
                        SpaceEntity(
                            id: space.id,
                            name: space.name,
                            thumbnailURL: await ThumbnailCache.shared.cachedImageURL(for: space),
                            editedAt: space.editedAt,
                            createdAt: space.createdAt
                        )
                    }
                }
                
                for await s in group {
                    entities.append(s)
                }
                
                if let sortedBy {
                    return entities.sorted(by: sortedBy)
                } else {
                    return entities.sorted {
                        $0.name.localizedStandardCompare($1.name) == .orderedAscending
                    }
                }
            }
        }
        
        func entities(matching string: String) async throws -> [SpaceEntity] {
            guard let token = Storage.getToken() else {
                return []
            }
            
            let spaces = try await Networking.getUserSpaces(token: token)
            let filteredSpaces = spaces.filter { $0.name.localizedCaseInsensitiveContains(string) }
            
            return await entitiesFrom(spaces: filteredSpaces)
        }
        
        func entities(for identifiers: [SpaceEntity.ID]) async throws -> [SpaceEntity] {
            guard let token = Storage.getToken() else {
                return []
            }
            
            let spaces = try await Networking.getUserSpaces(token: token)
            let filteredSpaces = spaces.filter { identifiers.contains($0.id) }
            return await entitiesFrom(spaces: filteredSpaces)
        }
        
        func suggestedEntities() async throws -> [SpaceEntity] {
            guard let token = Storage.getToken() else {
                return []
            }
            
            let spaces = try await Networking.getUserSpaces(token: token)
            let mostRecentSpaces = spaces.sortedByLastEditedAt.prefix(100)
            return await entitiesFrom(spaces: Array(mostRecentSpaces)) { a, b in
                let aDate = a.editedAt ?? a.createdAt
                let bDate = b.editedAt ?? b.createdAt
                return aDate.compare(bDate) == .orderedDescending
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
        attributes.thumbnailURL = thumbnailURL
        attributes.contentDescription = "Kinopio Space"
        
        return attributes
    }
    
}
