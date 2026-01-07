import SwiftUI
import AppIntents
import CoreSpotlight

@main
struct KinopioApp: App {
    
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    guard let token = Storage.getToken(), #available(iOS 18.0, *) else {
                        return
                    }
                    do {
                        let spaces = try await Networking.getUserSpaces(token: token)
                        let spaceEntitites = spaces
                            .map { space in
                                SpaceEntity(id: space.id, name: space.name)
                            }
                        try await CSSearchableIndex.default().indexAppEntities(
                            spaceEntitites
                        )
                    } catch {
                        print(error)
                    }
                }
        }
        .onChange(of: scenePhase) { scenePhase in
            if scenePhase == .background {
                if #available(iOS 18.0, *) {
                    ShortcutsProvider.updateAppShortcutParameters()
                }
            }
        }
    }
}
