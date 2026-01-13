import SwiftUI
import AppIntents
import CoreSpotlight

@main
struct KinopioApp: App {
    
    @Environment(\.scenePhase) private var scenePhase
    
    func indexSpaces() async {
        let date = Date().timeIntervalSinceReferenceDate
        
        guard let token = Storage.getToken(), #available(iOS 18.0, *) else {
            return
        }
        do {
            // MARK: - Index Spaces
            let spaces = try await Networking.getUserSpaces(token: token)
            var spaceEntities = [SpaceEntity]()
            
            for space in spaces {
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
            try await CSSearchableIndex.default().indexAppEntities(spaceEntities)
            
            // MARK: - Warmup Thumbnail Caches
            await withTaskGroup { group in
                for space in spaces.prefix(30) {
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
