//
//  LiveActivityLiveActivity.swift
//  LiveActivity
//
//  Created by Hendrik Nicolas Carlo on 09/05/25.
//
import ActivityKit
import WidgetKit
import SwiftUI

struct LiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveActivityAttributes.self) { context in
            // Lock screen/banner UI
            VStack(alignment: .leading) {
                Text(context.state.cycle)
                    .foregroundStyle(.fontApp)
                HStack {
                    Text(context.state.endDate, style: .timer)
                        .font(.system(size: 36, weight: .bold, design: .default))
                        .foregroundColor(.fontApp)
                    Spacer()
                    HStack(spacing:-1) {
                        Image("work-sit")
                            .resizable()
                            .frame(width: 20, height: 20)
                        Text("\(context.state.countWork)h |")
                            .foregroundStyle(.fontApp)
                        Image("walking")
                            .resizable()
                            .frame(width: 20, height: 20)
                        Text("\(context.state.countBreak)m")
                            .foregroundStyle(.fontApp)
                    }
                }
                .padding(.top, 10)
            }
            .padding(10)
            .activityBackgroundTint(.primaryApp)
            .activitySystemActionForegroundColor(.fontApp)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text(context.state.cycle)
                        .font(.headline)
                        .padding(.top, 5)
                        .lineLimit(1)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack(alignment: .bottom) {
                        Text(context.state.endDate, style: .timer)
                            .font(.system(size: 48, weight: .bold, design: .default))
                            .foregroundColor(.fontApp)
                        Spacer()
                        VStack(alignment: .trailing) {
                            Spacer()
                            HStack(spacing: -1) {
                                Image("work-sit")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                Text("\(context.state.countWork)h |")
                                    .foregroundStyle(.fontApp)
                                Image("walking")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                Text("\(context.state.countBreak)m")
                                    .foregroundStyle(.fontApp)
                            }
                        }
                        .padding(.vertical, 9)
                    }
                    .frame(height: 50)
                }
            } compactLeading: {
                Image(context.state.image)
                    .resizable()
                    .frame(width: 20, height: 20)
            } compactTrailing: {
                if context.state.endDate.timeIntervalSince(.now) > 60*60 {
                    Text("00:00:00")
                        .hidden()
                        .overlay(alignment: .trailing) {
                            DateTimerView(date: context.state.endDate)
                        }
                }else {
                    Text("00:00")
                        .hidden()
                        .overlay(alignment: .trailing) {
                            DateTimerView(date: context.state.endDate)
                        }
                }
            } minimal: {
                Image(context.state.image)
                    .resizable()
                    .frame(width: 20, height: 20)
            }
        }
    }
}


extension LiveActivityAttributes {
    static var preview: LiveActivityAttributes {
        LiveActivityAttributes(Id: "World")
    }
}

extension LiveActivityAttributes.ContentState {
    static var smiley: LiveActivityAttributes.ContentState {
        LiveActivityAttributes.ContentState(
            cycle: "Break",
            endDate: Date().addingTimeInterval(60*70), // 1 hour from now
            countWork: 4,
            countBreak: 10
        )
    }
    
    static var starEyes: LiveActivityAttributes.ContentState {
        LiveActivityAttributes.ContentState(
            cycle: "Work",
            endDate: Date().addingTimeInterval(60*5), // 2 hours from now
            countWork: 5,
            countBreak: 11
        )
    }
}

#Preview("Notification", as: .content, using: LiveActivityAttributes.preview) {
    LiveActivity()
} contentStates: {
    LiveActivityAttributes.ContentState.smiley
    LiveActivityAttributes.ContentState.starEyes
}
