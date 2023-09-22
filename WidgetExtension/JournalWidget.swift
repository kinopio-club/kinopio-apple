import WidgetKit
import SwiftUI

extension JournalWidget {
  struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> Entry {
      let sampleEntry = Entry.generateSampleEntry()
      return sampleEntry
    }
    
    func getSnapshot(in context: Context, completion: @escaping (Entry) -> ()) {
      let sampleEntry = Entry.generateSampleEntry()
      completion(sampleEntry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
      let date = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: Date(), repeatedTimePolicy: .last)!
      
      Task {
        do {
          let prompt = try await Networking.getJournalDailyPrompt()
          
          let entry = Entry(
            date: date,
            journalDailyPrompt: prompt.name,
            moonPhase: .getFrom()
          )
          let timeline = Timeline(
            entries: [entry],
            policy: .atEnd
          )
          
          completion(timeline)
        } catch {
          let entry = Entry(
            date: date,
            journalDailyPrompt: "",
            moonPhase: .getFrom(),
            isNetworkError: true
          )
          let timeline = Timeline(entries: [entry], policy: .atEnd)
          completion(timeline)
        }
      }
      
    }
  }
}

extension JournalWidget {
  struct Entry: TimelineEntry {
    let date: Date
    let journalDailyPrompt: String
    let moonPhase: MoonPhase
    var isNetworkError = false

    static func generateSampleEntry(isNetworkError: Bool = false) -> Entry {
      let journalDailyPrompt: String = "What are three small ways you can improve your relationships today?"
      var entry = Entry(
        date: Date(),
        journalDailyPrompt: journalDailyPrompt,
        moonPhase: .getFrom()
      )
      entry.isNetworkError = isNetworkError
      return entry
    }
  }
}

struct JournalWidgetView : View {
  var entry: JournalWidget.Entry
  
  @Environment(\.colorScheme) var colorScheme: ColorScheme
  
  let green = Color(hex: "#223C2F")
  
  @ViewBuilder
  func Header() -> some View {
    HStack {
      Image("LogoBase")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 24)
      
      Spacer()
      
      Text(entry.date.formatted(.dateTime.day().weekday().month(.wide)))
        .font(.caption2)
        .fontWeight(.medium)
        .foregroundColor(.white)
        .lineLimit(1)
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
  
  var body: some View {
    VStack {
      if !entry.isNetworkError {
        VStack(alignment: .leading) {
          Header()
          Spacer()
          Text(entry.journalDailyPrompt)
            .font(.caption)
            .lineSpacing(1.5)
            .foregroundColor(.white)
          Spacer()
          WidgetButton {
            Image(systemName: "plus")
            entry.moonPhase.image
              .foregroundColor(.black)
            Text("Daily Journal")
              .fontWeight(.medium)
          }
        }
      } else {
        Text("(シ_ _)シ There was a network error")
          .font(.caption)
          .foregroundColor(.white)
      }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(green)
    .widgetURL(Configuration.newJournalURL)
  }
}

struct JournalWidget: Widget {
  let kind: String = "JournalWidget"
  
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: Provider()) { entry in
      JournalWidgetView(entry: entry)
    }
    .configurationDisplayName("Daily Journal")
    .description("Make a new journal space, or open your existing one.")
    .supportedFamilies([.systemSmall])
  }
}

struct JournalWidget_Previews: PreviewProvider {
  static var previews: some View {
    let sampleEntry = JournalWidget.Entry.generateSampleEntry()
    let networkErrorEntry = JournalWidget.Entry.generateSampleEntry(isNetworkError: true)
    Group {
      JournalWidgetView(entry: sampleEntry)
        .previewContext(WidgetPreviewContext(family: .systemSmall))
        .previewDisplayName("JournalWidget")
      
      JournalWidgetView(entry: sampleEntry)
        .previewContext(WidgetPreviewContext(family: .systemSmall))
        .previewDisplayName("JournalWidget Placeholder")
      
      JournalWidgetView(entry: networkErrorEntry)
        .previewContext(WidgetPreviewContext(family: .systemSmall))
        .previewDisplayName("JournalWidget Network Error")
    }
    
  }
}
