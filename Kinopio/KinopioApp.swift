import SwiftUI
import AppIntents
import CoreSpotlight

@main
struct KinopioApp: App {
    
    @Environment(\.scenePhase) private var scenePhase
    
    func indexSpaces() async {
        guard let token = Storage.getToken(), #available(iOS 18.0, *) else {
            return
        }
        let index = CSSearchableIndex.default()
        
        do {
            // MARK: - Index Spaces
            let spaces = try await Networking.getUserSpaces(token: token)
            let mostRecentSpaces = spaces.sortedByLastEditedAt
            var spaceEntities = [SpaceEntity]()
            
            for space in mostRecentSpaces {
                spaceEntities.append(
                    SpaceEntity(
                        id: space.id,
                        name: space.name,
                        thumbnailURL: await ThumbnailCache.shared.cachedImageURL(for: space),
                        editedAt: space.editedAt,
                        createdAt: space.createdAt
                    )
                )
            }
            try await index.indexAppEntities(spaceEntities)
            
            // MARK: - Warmup Thumbnail Caches
            await withTaskGroup { group in
                for space in mostRecentSpaces {
                    group.addTask {
                        let _ = try? await ThumbnailCache.shared.imageURL(for: space)
                    }
                }
                await group.waitForAll()
            }
        } catch {
            print(error)
        }
        
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .task { await indexSpaces() }
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
