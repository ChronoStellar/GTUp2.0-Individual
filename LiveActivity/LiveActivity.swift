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
            // Lock screen/banner UI goes here
            VStack(alignment: .leading) {
                Text(context.state.cycle)
                    .foregroundStyle(.fontApp)
                HStack {
                    Text("\(context.state.timer)")
                        .font(.system(size: 36, weight: .bold, design: .default))
                        .foregroundColor(.fontApp)
                    Spacer()
                    HStack {
                        Image("workspace")
                            .resizable()
                            .frame(width: 20, height: 20)
                        Text("\(context.state.countWork)H |").foregroundStyle(.fontApp)
                        Image("walking")
                            .resizable()
                            .frame(width: 20, height: 20)
                        Text("\(context.state.countBreak)m").foregroundStyle(.fontApp)
                    }
                }.padding(.top,10)
            }
            .padding(10)
            .activityBackgroundTint(.primaryApp)
            .activitySystemActionForegroundColor(.fontApp)
            .background(.primaryApp)

        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text(context.state.cycle)
                        .font(.headline)
                        .padding(.top,5)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack(alignment: .bottom) {
                        Text("\(context.state.timer)")
                            .font(.system(size: 48, weight: .bold, design: .default))
                            .foregroundColor(.fontApp)
                        Spacer()
                        VStack(alignment: .trailing) {
                            Spacer()
                            HStack {
                                Image("workspace")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                Text("\(context.state.countWork)H | ").foregroundStyle(.fontApp)
                                Image("walking")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                Text("\(context.state.countWork)m").foregroundStyle(.fontApp)
                            }
                        }
                        .padding(.vertical, 9)
                    }
                    .frame(height:50)
                    .background(.red)
//                    .padding(.vertical)
                }
            } compactLeading: {
                if context.state.cycle == "Break" {
                    Image("walking")
                        .resizable()
                        .frame(width: 20, height: 20)
                } else if context.state.cycle == "Work" {
                    Image("workspace")
                        .resizable()
                        .frame(width: 20, height: 20)
                }
            } compactTrailing: {
                Text("\(context.state.timer)")
            } minimal: {
                if context.state.cycle == "Break" {
                    Image("walking")
                        .resizable()
                        .frame(width: 20, height: 20)
                } else if context.state.cycle == "Work" {
                    Image("workspace")
                        .resizable()
                        .frame(width: 20, height: 20)
                }
            }
        }
    }
}

extension LiveActivityAttributes {
    fileprivate static var preview: LiveActivityAttributes {
        LiveActivityAttributes(ID: "World")
    }
}

extension LiveActivityAttributes.ContentState {
    fileprivate static var smiley: LiveActivityAttributes.ContentState {
        LiveActivityAttributes.ContentState(cycle: "Break", timer:"10:10", countWork: 4, countBreak: 10)
     }
     
     fileprivate static var starEyes: LiveActivityAttributes.ContentState {
         LiveActivityAttributes.ContentState(cycle: "Work", timer:"10:10", countWork: 4, countBreak: 10)
     }
}

#Preview("Notification", as: .content, using: LiveActivityAttributes.preview) {
   LiveActivity()
} contentStates: {
    LiveActivityAttributes.ContentState.smiley
    LiveActivityAttributes.ContentState.starEyes
}
