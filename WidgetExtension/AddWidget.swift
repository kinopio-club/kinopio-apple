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
        return completion(Timeline(entries: [.unauthorized], policy: .never))
      }
      
      Task {
        do {
          let space = try await Networking.getUserInboxSpace(token: token)
          let user = try await Networking.getUser(token: token)
            
          // Cache for offline usage
          Storage.setUserColor(user.color)
          Storage.setNumberOfCards(space.cards?.count ?? 0)
          
          let entry = Entry(
            date: date,
            numberOfCards: space.cards?.count ?? 0,
            userColor: user.nativeColor,
            state: .default
          )
          let timeline = Timeline(
            entries: [entry],
            policy: .atEnd
          )
          
          completion(timeline)
        } catch Networking.APIError.unauthorized, Networking.APIError.forbidden {
            return completion(Timeline(entries: [.unauthorized], policy: .never))
        } catch {
            if let userColor = Storage.getUserColor(),
               let numberOfCards = Storage.getNumberOfCards() {
                let entry = Entry(
                  date: date,
                  numberOfCards: numberOfCards,
                  userColor: Color.parseWebColor(userColor) ?? .accentColor,
                  state: .default
                )
                let timeline = Timeline(
                  entries: [entry],
                  policy: .atEnd
                )
                completion(timeline)
            } else {
                completion(Timeline(entries: [.networkError], policy: .atEnd))
            }
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
    var state: State

    static func generateSampleEntry(state: State = .default, isPreview: Bool = false, numberOfCards: Int = 10) -> Entry {
      return Entry(
        date: .now,
        numberOfCards: numberOfCards,
        isPreview: isPreview,
        state: state
      )
    }
      
    static var unauthorized: Self {
        .init(date: .now, state: .unauthorized)
    }
      
    static var networkError: Self {
        let date = Calendar.current.date(byAdding: .minute, value: 15, to: .now)!
        return .init(date: date, state: .networkError)
    }
      
    enum State {
      case `default`, networkError, unauthorized
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
        switch entry.state {
        case .default:
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
        case .networkError:
            Text("(シ_ _)シ There was a network error")
              .font(.caption)
              .foregroundColor(.white)
        case .unauthorized:
            Text("You have to sign in to Kinopio before using this widget")
              .font(.caption)
              .foregroundColor(.white)
        }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .widgetBackground(green)
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
          .opacity(0.8)
        Text(entry.numberOfCards.description)
          .font(.headline)
      }
      .padding()
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .widgetBackground(Color.black.ignoresSafeArea())
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
      .widgetBackground(Color.black.ignoresSafeArea())
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
    .contentMarginsDisabled()
  }
}

@available(iOS 17.0, *)
#Preview("AddWidget", as: .systemSmall) {
    AddWidget()
} timeline: {
    return [AddWidget.Entry.generateSampleEntry()]
}

@available(iOS 17.0, *)
#Preview("AddWidget Placeholder", as: .systemSmall) {
    AddWidget()
} timeline: {
    return [AddWidget.Entry.generateSampleEntry(isPreview: true, numberOfCards: 21)]
}

@available(iOS 17.0, *)
#Preview("AddWidget No Auth", as: .systemSmall) {
    AddWidget()
} timeline: {
    return [AddWidget.Entry.unauthorized]
}

@available(iOS 17.0, *)
#Preview("AddWidget Network Error", as: .systemSmall) {
    AddWidget()
} timeline: {
    return [AddWidget.Entry.networkError]
}

@available(iOS 17.0, *)
#Preview("AddWidget Lock Screen Circular", as: .accessoryCircular) {
    AddWidget()
} timeline: {
    return [AddWidget.Entry.generateSampleEntry()]
}

@available(iOS 17.0, *)
#Preview("AddWidget Lock Screen Rectangular", as: .accessoryRectangular) {
    AddWidget()
} timeline: {
    return [AddWidget.Entry.generateSampleEntry()]
}

@available(iOS 17.0, *)
#Preview("AddWidget Lock Screen Inline", as: .accessoryInline) {
    AddWidget()
} timeline: {
    return [AddWidget.Entry.generateSampleEntry()]
}
