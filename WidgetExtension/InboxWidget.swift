import WidgetKit
import SwiftUI

extension InboxWidget {
    struct Provider: TimelineProvider {
        func placeholder(in context: Context) -> Entry {
            Entry(date: Date(), card: "This is the most recent card in your inbox.")
        }
        
        func getSnapshot(in context: Context, completion: @escaping (Entry) -> ()) {
            let entry = Entry(date: Date(), card: "This is the most recent card in your inbox.")
            completion(entry)
        }
        
        func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
            var entries: [Entry] = []
            
            // Generate a timeline consisting of five entries an hour apart, starting from the current date.
            let currentDate = Date()
            for hourOffset in 0 ..< 5 {
                let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
                let entry = Entry(date: entryDate, card: "This is the most recent card in your inbox.")
                entries.append(entry)
            }
            
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        }
    }
}

extension InboxWidget {
    struct Entry: TimelineEntry {
        let date: Date
        let card: String
        var userColor: Color = Color("AccentColor")
        var isPreview = false
    }
}

struct InboxWidgetView : View {
    var entry: InboxWidget.Entry
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    var isDarkMode: Bool { colorScheme == .dark }
    
    @ViewBuilder
    func InputForm() -> some View {
        HStack(alignment: .bottom, spacing: 4) {
            AvatarView(color: entry.userColor, size: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Type text here")
                    .foregroundColor(isDarkMode ? Color(hex: "#898989") : .black.opacity(0.4))
                    .font(.system(size: 11))
                
                Rectangle()
                    .foregroundColor(isDarkMode ? Color(hex: "4D4D4D") : .black)
                    .frame(height: 1)
            }
        }
    }
    
    @ViewBuilder
    func Card(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 0) {
            Text(text)
                .multilineTextAlignment(.leading)
                .font(.caption)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
            
            Circle()
                .stroke(isDarkMode ? Color(hex: "#666666") : .black.opacity(0.4))
                .frame(width: 14, height: 14)
        }
        .padding(6)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isDarkMode ? Color(hex: "#262626") : Color.secondaryBackground)
        )
    }
    
    @ViewBuilder
    func AddButton() -> some View {
        HStack(spacing: 2) {
            Image(systemName: "plus")
            Text("Add")
        }
        .labelStyle(.titleAndIcon)
        .buttonStyle(.plain)
        .font(.caption)
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .stroke(isDarkMode ? .white : .black)
        )
    }
    
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading) {
                Text("Add to Inbox")
                    .font(.footnote)
                    .fontWeight(.bold)
                
                InputForm()
                
                AddButton()
                
                if entry.isPreview {
                    Card(entry.card)
                        .padding(.top, 4)
                        .redacted(reason: .placeholder)
                } else {
                    Card(entry.card)
                        .padding(.top, 4)
                }
                
            }
            .frame(height: geometry.size.height, alignment: .top)
        }
        .padding()
        .widgetURL(Configuration.addUrl)
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
            InboxWidgetView(entry: InboxWidget.Entry(date: Date(), card: "This is the most recent card in your inbox."))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDisplayName("InboxWidget")
            
            InboxWidgetView(entry: InboxWidget.Entry(date: Date(), card: "This is the most recent card in your inbox.", isPreview: true))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDisplayName("InboxWidget Placeholder")
        }
        
    }
}
