//
//  myWidget.swift
//  myWidget
//
//  Created by sunyuan on 2025/5/25.
//

import WidgetKit
import SwiftUI
import AppIntents

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        print("[Widget-Provider] placeholder called")
        return SimpleEntry(date: Date(), counter: 0)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let counter = SharedUserDefaults.shared.getCounter()
        print("[Widget-Provider] getSnapshot called, counter=\(counter)")
        let entry = SimpleEntry(date: Date(), counter: counter)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let counter = SharedUserDefaults.shared.getCounter()
        let currentDate = Date()
        print("[Widget-Provider] getTimeline called, counter=\(counter), date=\(currentDate)")
        let entry = SimpleEntry(date: currentDate, counter: counter)
        
        // 每5分钟更新一次
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let counter: Int
}

struct myWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            smallWidget
        case .systemMedium:
            mediumWidget
        case .systemLarge:
            largeWidget
        default:
            smallWidget
        }
    }
    
    // 小尺寸布局
    private var smallWidget: some View {
        VStack(spacing: 8) {
            Text("计数器")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("\(entry.counter)")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.blue)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            
            HStack(spacing: 16) {
                Button(intent: DecrementIntent()) {
                    Image(systemName: "minus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.red)
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(intent: IncrementIntent()) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            Text("点击 +/- 操作")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
    }
    
    // 中尺寸布局
    private var mediumWidget: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("计数器")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("当前值:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("\(entry.counter)")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.blue)
                .minimumScaleFactor(0.6)
            
            Spacer()
            
            VStack(spacing: 12) {
                Button(intent: IncrementIntent()) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                        .foregroundColor(.green)
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(intent: DecrementIntent()) {
                    Image(systemName: "minus.circle.fill")
                        .font(.title)
                        .foregroundColor(.red)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
    }
    
    // 大尺寸布局
    private var largeWidget: some View {
        VStack {
            Text("计数器")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top)
            
            Text("\(entry.counter)")
                .font(.system(size: 72, weight: .bold))
                .foregroundColor(.blue)
                .padding()
                .minimumScaleFactor(0.7)
            
            HStack(spacing: 40) {
                Button(intent: DecrementIntent()) {
                    VStack {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 40))
                        Text("减少")
                            .font(.caption)
                    }
                    .foregroundColor(.red)
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(intent: IncrementIntent()) {
                    VStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 40))
                        Text("增加")
                            .font(.caption)
                    }
                    .foregroundColor(.green)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding()
            
            Text("上次更新: \(formatDate(entry.date))")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom)
        }
        .padding()
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct myWidget: Widget {
    let kind: String = "myWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                myWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                myWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("计数器小组件")
        .description("显示当前计数并支持点击增减操作")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// App Intent for increment
struct IncrementIntent: AppIntent {
    static var title: LocalizedStringResource = "增加计数"
    static var description = IntentDescription("将计数器值增加1")
    
    func perform() async throws -> some IntentResult {
        print("[Widget-IncrementIntent] perform called")
        SharedUserDefaults.shared.incrementCounter()
        
        // 刷新小组件
        WidgetCenter.shared.reloadTimelines(ofKind: "myWidget")
        
        return .result()
    }
}

// App Intent for decrement
struct DecrementIntent: AppIntent {
    static var title: LocalizedStringResource = "减少计数"
    static var description = IntentDescription("将计数器值减少1")
    
    func perform() async throws -> some IntentResult {
        print("[Widget-DecrementIntent] perform called")
        SharedUserDefaults.shared.decrementCounter()
        
        // 刷新小组件
        WidgetCenter.shared.reloadTimelines(ofKind: "myWidget")
        
        return .result()
    }
}

#Preview(as: .systemSmall) {
    myWidget()
} timeline: {
    SimpleEntry(date: .now, counter: 0)
    SimpleEntry(date: .now, counter: 5)
    SimpleEntry(date: .now, counter: -3)
}

#Preview(as: .systemMedium) {
    myWidget()
} timeline: {
    SimpleEntry(date: .now, counter: 0)
    SimpleEntry(date: .now, counter: 42)
}

#Preview(as: .systemLarge) {
    myWidget()
} timeline: {
    SimpleEntry(date: .now, counter: 0)
    SimpleEntry(date: .now, counter: 99)
}
