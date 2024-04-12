//
//  QuickDropWidgetLiveActivity.swift
//  QuickDropWidget
//
//  Created by Adam Cseke on 07/04/2024.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct QuickDropWidgetAttributes: ActivityAttributes {
  public struct ContentState: Codable, Hashable {
    var startDate: Date?
    var endDate: Date?
    var halfMinuteLeft: Bool = true
    var minutesLeft: Int?
    var timerEnded: Bool = false

    func getActivityDateRange() -> ClosedRange<Date>? {
      guard let startDate = startDate, let endDate = endDate else {
        return nil
      }
      return startDate...endDate
    }
  }
}

struct QuickDropWidgetLiveActivity: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: QuickDropWidgetAttributes.self) { context in
      VStack(alignment: .leading) {
        HStack {
          if context.state.timerEnded {
            HStack {
              Image("CountdownEndedX")
                .resizable()
                .frame(width: 32, height: 32, alignment: .center)
              Text("You lost your place")
                .font(.system(size: 15, weight: .bold, design: .default))
                .foregroundStyle(.white)
                .padding(.leading, 8)
            }
            Spacer()

            Image("NotificationBBlogo")
              .resizable()
              .frame(width: 36, height: 36, alignment: .center)
          } else {
            if context.state.halfMinuteLeft {
              HStack {
                if let range = context.state.getActivityDateRange() {
                  ProgressView(
                    timerInterval: range,
                    countsDown: true,
                    label: { EmptyView() },
                    currentValueLabel: {
                      Text(timerInterval: range, countsDown: true)
                        .font(.system(size: 16, weight: .bold, design: .default))
                        .rotationEffect(.degrees(-90))
                    }
                  )
                  .progressViewStyle(.circular)
                  .foregroundStyle(.blue)
                  .tint(.blue)
                  .frame(width: 48, height: 48, alignment: .center)
                  .rotationEffect(.degrees(90))
                }
                Text("seconds to connect")
                  .font(.system(size: 15, weight: .bold, design: .default))
                  .foregroundStyle(.white)
                  .padding(.leading, 8)
              }
            } else {
              Text("\(context.state.minutesLeft ?? 0) min")
                .foregroundStyle(.white)
                .font(.system(size: 24, weight: .bold, design: .default))
            }

            Spacer()

            Image("NotificationBBlogo")
              .resizable()
              .frame(width: 36, height: 36, alignment: .center)

          }
        }

        Text(context.state.timerEnded ? "You lost your place in line, since you did not connect within 30 seconds." : (context.state.halfMinuteLeft ? "The Smart Bin is ready for you, you have 30 seconds to connect" : "There are 3 people in front of you, you need to wait approx. 4 minutes"))
          .font(.system(size: 13))
          .foregroundStyle(.white)
          .multilineTextAlignment(.leading)
          .lineLimit(nil)
          .fixedSize(horizontal: false, vertical: true)
          .padding(.top, 8)
      }
      .padding(24)
      .activityBackgroundTint(.black.opacity(0.4))
    } dynamicIsland: { context in
      DynamicIsland {
        DynamicIslandExpandedRegion(.leading) {
          if context.state.timerEnded {
            HStack {
              Image("CountdownEndedX")
                .resizable()
                .frame(width: 32, height: 32, alignment: .center)
            }
          } else {
            if context.state.halfMinuteLeft {
              if let range = context.state.getActivityDateRange() {
                ProgressView(
                  timerInterval: range,
                  countsDown: true,
                  label: { EmptyView() },
                  currentValueLabel: {
                    Text(timerInterval: range, countsDown: true)
                      .font(.system(size: 16, weight: .bold, design: .default))
                      .rotationEffect(.degrees(-90))
                  }
                )
                .progressViewStyle(.circular)
                .foregroundStyle(.blue)
                .tint(.blue)
                .frame(width: 48, height: 48, alignment: .center)
                .rotationEffect(.degrees(90))
              }
            } else {
              Text("\(context.state.minutesLeft ?? 0) min")
                .font(.system(size: 16, weight: .bold, design: .default))
                .frame(width: 48, height: 48, alignment: .center)
                .frame(maxHeight: 48)
            }
          }
        }

        DynamicIslandExpandedRegion(.center) {
          Text(context.state.timerEnded ? "You lost your place in line, since you did not connect within 30 seconds." : "There are 3 people in front of you, you need to wait approx. \(context.state.minutesLeft ?? 0) minutes")
            .foregroundStyle(.white)
            .font(.system(size: 12, weight: .bold, design: .default))
            .frame(maxHeight: 48, alignment: .top)
            .foregroundStyle(.white)
            .lineLimit(2)
            .fixedSize(horizontal: false, vertical: true)
            .multilineTextAlignment(.center)
        }

        DynamicIslandExpandedRegion(.trailing) {
          Image("bottlebanklogo")
            .resizable()
            .frame(width: 36, height: 36, alignment: .center)
        }

      } compactLeading: {
        if context.state.timerEnded {
          HStack {
            Image("CountdownEndedX")
              .resizable()
              .frame(width: 24, height: 24, alignment: .center)
          }
        } else {
          if context.state.halfMinuteLeft {
            if let range = context.state.getActivityDateRange() {
              ProgressView(
                timerInterval: range,
                countsDown: true,
                label: { EmptyView() },
                currentValueLabel: {
                  Text(timerInterval: range, countsDown: true)
                    .font(.system(size: 8, weight: .bold, design: .default))
                    .rotationEffect(.degrees(-90))
                }
              )
              .progressViewStyle(.circular)
              .foregroundStyle(.blue)
              .tint(.blue)
              .frame(width: 24, height: 24, alignment: .center)
              .rotationEffect(.degrees(90))
            }
          } else {
            Text("\(context.state.minutesLeft ?? 0) min")
          }
        }
      } compactTrailing: {
        Image("bottlebanklogo")
          .imageScale(.medium)
      } minimal: {
        if context.state.timerEnded {
          HStack {
            Image("CountdownEndedX")
              .resizable()
              .frame(width: 24, height: 24, alignment: .center)
          }
        } else {
          if context.state.halfMinuteLeft {
            if let range = context.state.getActivityDateRange() {
              ProgressView(
                timerInterval: range,
                countsDown: true,
                label: { EmptyView() },
                currentValueLabel: {
                  Text(timerInterval: range, countsDown: true)
                    .font(.system(size: 8, weight: .bold, design: .default))
                    .rotationEffect(.degrees(-90))
                }
              )
              .progressViewStyle(.circular)
              .foregroundStyle(.blue)
              .tint(.blue)
              .frame(width: 24, height: 24, alignment: .center)
              .rotationEffect(.degrees(90))
            }
          } else {
            Text("\(context.state.minutesLeft ?? 0) min")
              .font(.system(size: 10, weight: .bold, design: .default))
          }
        }
      }
      .widgetURL(URL(string: "http://www.apple.com"))
      .keylineTint(Color.red)
    }
  }
}

extension QuickDropWidgetAttributes {
  fileprivate static var preview: QuickDropWidgetAttributes {
    QuickDropWidgetAttributes()
  }
}

extension QuickDropWidgetAttributes.ContentState {
  fileprivate static var starEyes: QuickDropWidgetAttributes.ContentState {
    QuickDropWidgetAttributes.ContentState(startDate: Date(), minutesLeft: 1)
  }
}

#Preview("Notification", as: .content, using: QuickDropWidgetAttributes.preview) {
  QuickDropWidgetLiveActivity()
} contentStates: {
  QuickDropWidgetAttributes.ContentState.starEyes
}
