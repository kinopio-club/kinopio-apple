import Foundation
import AppIntents

struct CreateCardIntent: AppIntent {
    static var title: LocalizedStringResource = "Create new card"
    
    @Parameter(
        title: "Name",
        description: "The name of the card is its main text",
        requestValueDialog: .nameParameterPrompt
    )
    var name: String
    
    @Parameter(
        title: "Space",
        description: "The space that the card belongs to",
        requestValueDialog: .spaceParameterPrompt
    )
    var space: SpaceEntity
    
    @Parameter(title: "x", description: "The x-axis position")
    var x: Int?
    
    @Parameter(title: "y", description: "The y-axis position")
    var y: Int?
    
    @Parameter(title: "z", description: "The z-axis position")
    var z: Int?
    
    static var parameterSummary: some ParameterSummary {
        Summary("Create new card with name \(\.$name) in \(\.$space)") {
            \.$x
            \.$y
            \.$z
        }
    }
    
    
    func perform() async throws -> some IntentResult & ReturnsValue<SpaceEntity> {
        guard let token = Storage.getToken() else {
            throw IntentError.notAuthenticated
        }
        
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            name = try await $name.requestValue(.nameParameterPrompt)
        }
        
        let card = Card(
            id: UUID().uuidString,
            name: name,
            spaceId: space.id,
            x: x,
            y: y,
            z: z
        )
        
        do {
            let card = try await Networking.createCard(token: token, card: card)
            return .result(value: SpaceEntity(id: card.id, name: name))
        } catch Networking.APIError.unauthorized {
            throw IntentError.notAuthenticated
        }
        catch {
            throw IntentError.unknown(message: error.localizedDescription)
        }
    }
    
}

fileprivate extension IntentDialog {
    static var nameParameterPrompt: Self {
        "Please define the name of the card."
    }
    static var spaceParameterPrompt: Self {
        "Please select the space your card should get created in."
    }
}
