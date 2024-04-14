//
//  QuickDropWidgetModule.swift
//  QuickDropLiveActivity
//
//  Created by Adam Cseke on 07/04/2024.
//

import Foundation
import ActivityKit

@objc(QuickDropWidgetModule)
class QuickDropWidgetModule: NSObject {
  private var currentActivity: Activity<QuickDropWidgetAttributes>?
  private var startDate: Date?
  private var endDate: Date?
  private var halfMinuteLeft: Bool = false
  private var minutesLeft: Int?
  private var timerEnded: Bool?
  private var tenSecondsLeft: Bool = false

  private func areActivitiesEnabled() -> Bool {
    return ActivityAuthorizationInfo().areActivitiesEnabled
  }

  private func resetValues() {
    startDate = nil
    currentActivity = nil
  }

  @objc(startLiveActivity:endDateTimestamp:initialMinutesLeft:)
  func startLiveActivity(_ startDateTimestamp: Double, endDateTimestamp: Double, initialMinutesLeft minutesLeft: Int) {
    startDate = Date(timeIntervalSince1970: startDateTimestamp)
    endDate = Date(timeIntervalSince1970: endDateTimestamp)
    self.minutesLeft = minutesLeft

    if !areActivitiesEnabled() {
      print("Activities are not enabled.")
      return
    }

    let activityAttributes = QuickDropWidgetAttributes()
    let contentState = QuickDropWidgetAttributes.ContentState(
      startDate: startDate,
      endDate: endDate,
      halfMinuteLeft: halfMinuteLeft,
      minutesLeft: minutesLeft
    )

    let activityContent = ActivityContent(state: contentState, staleDate: nil)
    do {
      currentActivity = try Activity.request(attributes: activityAttributes, content: activityContent)
      print("Live Activity started with initial minutes left: \(minutesLeft)")
    } catch {
      print("Failed to start live activity: \(error.localizedDescription)")
    }
  }

  @objc(updateActivityState:halfMinuteLeft:)
  func updateActivityState(minutesLeft: Int, halfMinuteLeft: Bool) {
    self.minutesLeft = minutesLeft
    self.halfMinuteLeft = halfMinuteLeft

    if halfMinuteLeft {
      startDate = Date.now
    }

    guard let currentActivity = self.currentActivity,
          let startDate = self.startDate,
          let endDate = self.endDate else {
      print("Current activity, start date, or end date is nil.")
      return
    }

    Task {
      do {
        let updatedContentState = QuickDropWidgetAttributes.ContentState(startDate: startDate, endDate: endDate, halfMinuteLeft: halfMinuteLeft, minutesLeft: minutesLeft)
        try await currentActivity.update(using: updatedContentState)
        print("Live Activity updated with minutes left: \(minutesLeft), flag: \(halfMinuteLeft)")
      } catch {
        print("Failed to update the live activity: \(error)")
      }
    }
  }

  @objc(setTenSecondsLeft:)
  func setTenSecondsLeft(_ tenSecondsLeft: Bool) {
    self.tenSecondsLeft = tenSecondsLeft

    guard let currentActivity = self.currentActivity,
          let startDate = self.startDate,
          let endDate = self.endDate else {
      print("Current activity, start date, or end date is nil.")
      return
    }

    Task {
      do {
        let updatedContentState = QuickDropWidgetAttributes.ContentState(startDate: startDate, endDate: endDate, halfMinuteLeft: halfMinuteLeft, minutesLeft: minutesLeft, tenSecondsLeft: tenSecondsLeft)
        try await currentActivity.update(using: updatedContentState)
        print("Live Activity updated with minutes left: \(minutesLeft), flag: \(halfMinuteLeft)")
      } catch {
        print("Failed to update the live activity: \(error)")
      }
    }
  }

  @objc
  func timerHasEnded(_ ended: Bool) {
    guard let currentActivity = self.currentActivity,
          let startDate = self.startDate,
          let endDate = self.endDate else {
      print("Current activity, start date, or end date is nil.")
      return
    }

    Task {
      do {
        let updatedContentState = QuickDropWidgetAttributes.ContentState(
          startDate: startDate,
          endDate: endDate,
          halfMinuteLeft: self.halfMinuteLeft,
          minutesLeft: self.minutesLeft,
          timerEnded: ended
        )
        try await currentActivity.update(using: updatedContentState)
        print("Live Activity updated: Timer has ended.")
      } catch {
        print("Failed to update the live activity: \(error)")
      }
    }
  }

  @objc
  func stopLiveActivity() -> Void {
    startDate = nil
    endDate = nil
    Task {
      for activity in Activity<QuickDropWidgetAttributes>.activities {
        await activity.end(nil, dismissalPolicy: .immediate)
      }
    }
  }
}
