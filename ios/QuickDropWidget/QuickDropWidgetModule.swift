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
  private var timeLeftSeconds: Double?
  private var minutesLeft: Int?
  private var timerEnded: Bool?

  private func areActivitiesEnabled() -> Bool {
    return ActivityAuthorizationInfo().areActivitiesEnabled
  }

  private func resetValues() {
    startDate = nil
    currentActivity = nil
  }

  @objc
  func setStartDate(_ startDateTimestamp: Double) -> Void {
    startDate = Date(timeIntervalSince1970: startDateTimestamp)
  }

  @objc
  func setEndDate(_ endDateTimestamp: Double) -> Void {
    endDate = Date(timeIntervalSince1970: endDateTimestamp)
  }

  @objc
  func startLiveActivity(_ startDateTimestamp: Double) -> Void {
    startDate = Date(timeIntervalSince1970: startDateTimestamp)
    if (!areActivitiesEnabled()) {
      return
    }
    let activityAttributes = QuickDropWidgetAttributes()
    let contentState = QuickDropWidgetAttributes.ContentState(startDate: startDate, endDate: endDate)
    let activityContent = ActivityContent(state: contentState,  staleDate: nil)
    do {
      currentActivity = try Activity.request(attributes: activityAttributes, content: activityContent)
    } catch {
      print(error.localizedDescription)
    }
  }

  @objc func updateMinutesLeft(_ minutesLeft: Int) {
      guard let currentActivity = self.currentActivity else {
          print("Current activity is nil.")
          return
      }

      self.minutesLeft = minutesLeft

      let updatedContentState = QuickDropWidgetAttributes.ContentState(
          startDate: self.startDate,
          endDate: self.endDate,
          halfMinuteLeft: self.halfMinuteLeft,
          minutesLeft: minutesLeft
      )

      Task {
          do {
              try await currentActivity.update(using: updatedContentState)
              print("Live Activity updated with minutes left: \(minutesLeft)")
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
                  timeLeftSeconds: self.timeLeftSeconds,
                  minutesLeft: self.minutesLeft,
                  timerEnded: ended
              )
              try await currentActivity.update(using: updatedContentState)
              print("Live Activity updated: Timer has ended.")
          } catch {
              print("Failed to update the live activity: \(error)")
          }
      }

//      if ended {
//          stopLiveActivity()
//      }
  }

  @objc
  func updateTimeLeftSeconds(_ timeLeftSeconds: Double) {
      self.timeLeftSeconds = timeLeftSeconds

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
                  timeLeftSeconds: timeLeftSeconds,
                  minutesLeft: self.minutesLeft
              )
              try await currentActivity.update(using: updatedContentState)
              print("Live Activity updated with time left seconds: \(timeLeftSeconds)")
          } catch {
              print("Failed to update the live activity: \(error)")
          }
      }
  }


  @objc func updateHalfMinuteLeft(_ halfMinuteLeft: Bool) -> Void {
    startDate = Date.now
    self.halfMinuteLeft = halfMinuteLeft

    guard let currentActivity = self.currentActivity,
          let startDate = self.startDate,
          let endDate = self.endDate else {
      print("Current activity, start date, or end date is nil.")
      return
    }

    Task {
      do {
        let updatedContentState = QuickDropWidgetAttributes.ContentState(startDate: startDate, endDate: endDate, halfMinuteLeft: halfMinuteLeft)
        try await currentActivity.update(using: updatedContentState)
      } catch {
        print("Failed to update the live activity: \(error)")
      }
    }
  }

  @objc
  func stopLiveActivity() -> Void {
    startDate = nil
    endDate = nil
    // It helps to avoid blocking the main thread
    Task {
      for activity in Activity<QuickDropWidgetAttributes>.activities {
        await activity.end(nil, dismissalPolicy: .immediate)
      }
    }
  }
}
