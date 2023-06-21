import WidgetKit
import SwiftUI

extension InboxWidget {
    struct Provider: TimelineProvider {
        func placeholder(in context: Context) -> Entry {
            Entry(date: Date(), numberOfCards: 21, spacesNames: ["Random Space Name", "Another Random Space Name"], isPreview: true)
        }
        
        func getSnapshot(in context: Context, completion: @escaping (Entry) -> ()) {
            let entry = Entry(date: Date(), numberOfCards: 21, spacesNames: [])
            completion(entry)
        }
        
        func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
            let date = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
            
            guard let token = Storage.getToken() else {
                return completion(Timeline(entries: [Entry(date: date, numberOfCards: 0, spacesNames: [], isAuthenticated: false)], policy: .atEnd))
            }
            
            Task {
                do {
                    let space = try await Networking.getUserInboxSpace(token: token)
                    let user = try await Networking.getUser(token: token)
                    let spaces = try await Networking.getUserSpaces(token: token)
                    
                    let spaceNames = spaces.sorted {
                        $0.editedAt.compare($1.editedAt) == .orderedDescending
                    }
                        .map { $0.name }
                    
                    let entry = Entry(
                        date: date,
                        numberOfCards: space.cards?.count ?? 0,
                        spacesNames: Array(spaceNames[0...1]),
                        userColor: user.nativeColor,
                        isAuthenticated: true
                    )
                    let timeline = Timeline(
                        entries: [entry],
                        policy: .atEnd
                    )
                    
                    completion(timeline)
                } catch {
                    let entry = Entry(date: date, numberOfCards: 0, spacesNames: [], isAuthenticated: false)
                    let timeline = Timeline(entries: [entry], policy: .atEnd)
                    completion(timeline)
                }
            }
            
        }
    }
}

extension InboxWidget {
    struct Entry: TimelineEntry {
        let date: Date
        let numberOfCards: Int
        let spacesNames: [String]
        var userColor: Color = Color("AccentColor")
        var isPreview = false
        var isAuthenticated: Bool = true
    }
}

struct InboxWidgetView : View {
    var entry: InboxWidget.Entry
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    let green = Color(hex: "#223C2F")
    
    @ViewBuilder
    func Header() -> some View {
        HStack {
            AvatarView(color: entry.userColor, size: 20)
            
            Spacer()
            
            HStack(spacing: 4) {
                Image("Inbox")
                Text("\(entry.numberOfCards) Cards")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(.white)
        }
    }
    
    @ViewBuilder
    func WidgetButton<C: View>(@ViewBuilder content: () -> C) -> some View {
        HStack(spacing: 3) {
            content()
                .foregroundColor(.white)
        }
        .labelStyle(.titleAndIcon)
        .buttonStyle(.plain)
        .font(.caption)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .stroke(.white)
                .opacity(0.3)
        )
    }
    
    @ViewBuilder
    func ApplyPlaceholder<C: View>(@ViewBuilder content: () -> C) -> some View {
        if entry.isPreview {
            content().redacted(reason: .placeholder)
        } else {
            content()
        }
    }
    
    var body: some View {
        VStack {
            if entry.isAuthenticated {
                VStack(alignment: .leading) {
                    if entry.isPreview {
                        Header()
                            .redacted(reason: .placeholder)
                    } else {
                        Header()
                    }
                    
                    Spacer()
                    
                    ApplyPlaceholder {
                        WidgetButton {
                            Image(systemName: "plus")
                            Image("Inbox")
                            Text("Add To Inbox")
                                .fontWeight(.medium)
                        }
                        
                        ForEach(entry.spacesNames, id: \.self) { name in
                            
                            Spacer()
                            WidgetButton {
                                Text(name)
                                    .fontWeight(.medium)
                                    .lineLimit(1)
                            }
                            
                            
                        }
                    }
                }
                .widgetURL(Configuration.addUrl)
            } else {
                Text("You have to login to Kinopio before using this widget.")
                    .font(.caption)
                    .foregroundColor(.white)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(green)
    }
}

struct InboxWidget: Widget {
    let kind: String = "InboxWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            InboxWidgetView(entry: entry)
        }
        .configurationDisplayName("Add to Inbox")
        .description("Quickly add cards to your Inbox.")
        .supportedFamilies([.systemSmall])
    }
}

struct WidgetExtension_Previews: PreviewProvider {
    static var previews: some View {
        
        Group {
            InboxWidgetView(entry: InboxWidget.Entry(date: Date(), numberOfCards: 21, spacesNames: ["Last Space Name", "Another Space Name"]))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDisplayName("InboxWidget")
            
            InboxWidgetView(entry: InboxWidget.Entry(date: Date(), numberOfCards: 21, spacesNames: ["Random Space Name", "Another Random Space Name"], isPreview: true))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDisplayName("InboxWidget Placeholder")
            
            InboxWidgetView(entry: InboxWidget.Entry(date: Date(), numberOfCards: 0, spacesNames: [], isAuthenticated: false))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDisplayName("InboxWidget No Auth")
        }
        
    }
}
