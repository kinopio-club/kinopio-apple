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
                        
                        var spaceEntities = [SpaceEntity]()
                        for space in spaces {
                            spaceEntities.append(
                                SpaceEntity(
                                    id: space.id,
                                    name: space.name,
                                    thumbnailURL: try? await ThumbnailCache.shared.imageURL(for: space)
                                )
                            )
                        }
                        
                        try await CSSearchableIndex.default().indexAppEntities(
                            spaceEntities
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
