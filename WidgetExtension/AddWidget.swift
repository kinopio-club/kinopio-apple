import WidgetKit
import SwiftUI

extension AddWidget {
  struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> Entry {
      let sampleEntry = Entry.generateSampleEntry(isPreview: true)
      return sampleEntry
    }
    
    func getSnapshot(in context: Context, completion: @escaping (Entry) -> ()) {
      let sampleEntry = Entry.generateSampleEntry()
      completion(sampleEntry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
      let date = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
      
      guard let token = Storage.getToken() else {
        return completion(Timeline(entries: [Entry(date: date, numberOfCards: 0, isAuthenticated: false)], policy: .atEnd))
      }
      
      Task {
        do {
          let space = try await Networking.getUserInboxSpace(token: token)
          let user = try await Networking.getUser(token: token)
          
          let entry = Entry(
            date: date,
            numberOfCards: space.cards?.count ?? 0,
            userColor: user.nativeColor,
            isAuthenticated: true
          )
          let timeline = Timeline(
            entries: [entry],
            policy: .atEnd
          )
          
          completion(timeline)
        } catch {
          let entry = Entry(date: date, numberOfCards: 0, isAuthenticated: false)
          let timeline = Timeline(entries: [entry], policy: .atEnd)
          completion(timeline)
        }
      }
      
    }
  }
}

extension AddWidget {
  struct Entry: TimelineEntry {
    let date: Date
    var numberOfCards = 0
    var userColor: Color = Color("AccentColor")
    var isPreview = false
    var isAuthenticated: Bool = true

    static func generateSampleEntry(isAuthenticated: Bool = true, isPreview: Bool = false, numberOfCards: Int = 10) -> Entry {
      let userColor: Color = Color("AccentColor")
      var entry = Entry(
        date: Date(),
        userColor: userColor
      )
      entry.isAuthenticated = isAuthenticated
      entry.isPreview = isPreview
      entry.numberOfCards = numberOfCards
      return entry
    }
  }
}

struct AddWidgetView : View {
  var entry: AddWidget.Entry
  
  @Environment(\.widgetFamily) var family: WidgetFamily
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
    .frame(maxWidth: .infinity)
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
  
  func HomeScreen() -> some View {
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
              Text("Add Card")
                .fontWeight(.medium)
                .lineLimit(1)
            }
          }
        }
        .widgetURL(Configuration.addURL)
      } else {
        Text("You have to sign in to Kinopio before using this widget")
          .font(.caption)
          .foregroundColor(.white)
      }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(green)
  }
  
  func LockScreen() -> some View{
    Image("Inbox")
      .resizable()
      .padding()
      .background(green.ignoresSafeArea())
  }
  
  var body: some View {
    switch family {
    case .systemSmall, .systemMedium, .systemLarge, .systemExtraLarge:
      HomeScreen()
    case .accessoryCircular:
      VStack(spacing: 0) {
        Image("Inbox")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 18, height: 18)
          .opacity(0.6)
        Text(entry.numberOfCards.description)
          .font(.headline)
      }
      .padding()
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(Color.black.ignoresSafeArea())
      .widgetURL(Configuration.addURL)
    case .accessoryInline:
      Text("\(entry.numberOfCards) Cards in Inbox")
        .widgetURL(Configuration.addURL)
    case .accessoryRectangular:
      HStack {
        Image("Inbox")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 16)
        Text("\(entry.numberOfCards) Cards")
      }
      .widgetURL(Configuration.addURL)
    @unknown default:
      HomeScreen()
    }
  }
}

struct AddWidget: Widget {
  let kind: String = "AddWidget"
  
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: Provider()) { entry in
      AddWidgetView(entry: entry)
    }
    .configurationDisplayName("Add Card")
    .description("Add cards to your Inbox and other spaces.")
    .supportedFamilies([.systemSmall, .accessoryInline, .accessoryCircular, .accessoryRectangular])
  }
}

struct WidgetExtension_Previews: PreviewProvider {
  static var previews: some View {
    let sampleEntry = AddWidget.Entry.generateSampleEntry()
    let placeholderEntry = AddWidget.Entry.generateSampleEntry(isPreview: true, numberOfCards: 21)
    let noAuthEntry = AddWidget.Entry.generateSampleEntry(isAuthenticated: false)
    Group {
      AddWidgetView(entry: sampleEntry)
        .previewContext(WidgetPreviewContext(family: .systemSmall))
        .previewDisplayName("AddWidget")
      
      AddWidgetView(entry: placeholderEntry)
        .previewContext(WidgetPreviewContext(family: .systemSmall))
        .previewDisplayName("AddWidget Placeholder")
      
      AddWidgetView(entry: noAuthEntry)
        .previewContext(WidgetPreviewContext(family: .systemSmall))
        .previewDisplayName("AddWidget No Auth")
      
      AddWidgetView(entry: sampleEntry)
        .previewContext(WidgetPreviewContext(family: .accessoryCircular))
        .previewDisplayName("Lock Screen")
    }
    
  }
}
