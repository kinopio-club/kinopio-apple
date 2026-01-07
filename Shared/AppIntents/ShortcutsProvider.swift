import AppIntents

@available(iOS 18.0, *)
struct ShortcutsProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: OpenSpaceIntent(),
            phrases: [
                "Open \(\.$target) in \(.applicationName)",
            ],
            shortTitle: "Open Space",
            systemImageName: "heart.fill"
        )
    }
    
    static let shortcutTileColor: ShortcutTileColor = .lightBlue
}
