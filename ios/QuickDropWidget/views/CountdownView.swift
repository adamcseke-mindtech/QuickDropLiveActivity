//
//  CountdownView.swift
//  QuickDropLiveActivity
//
//  Created by Adam Cseke on 07/04/2024.
//

import SwiftUI

struct Clock: View {
  var timeLeft: TimeInterval
  var fontSize: CGFloat

  var body: some View {
    VStack {
      Text(timeLeftFormatted)
        .font(.system(size: fontSize))
        .fontWeight(.bold)
        .foregroundStyle(Color(timeLeft <= 10 ? Color("qdred") : Color("qdblue")))
    }
  }

  var timeLeftFormatted: String {
    let seconds = timeLeft < 60 ? Int(timeLeft) : Int(timeLeft) % 60
    return String(format: "%02d", seconds)
  }
}

struct ProgressBar: View {
  var timeLeft: TimeInterval
  var totalTime: TimeInterval
  var size: CGSize = CGSize(width: 24, height: 24)
  var lineWidth: CGFloat

  var body: some View {
    Circle()
      .fill(Color.clear)
      .frame(width: size.width, height: size.height)
      .overlay(
        Circle()
          .trim(from: 0, to: CGFloat(progress()))
          .stroke(
            style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt, lineJoin: .miter)
          )
          .foregroundColor(timeLeft <= 10 ? Color("qdred") : Color("qdblue"))
          .animation(.easeInOut(duration: 1.3), value: timeLeft)
      )
  }

  func progress() -> Double {
    return (timeLeft / totalTime)
  }
}

struct CountdownView: View {
  var endDate: Date
  @State var timeLeft: TimeInterval
  var size: Int
  var fontSize: CGFloat = 10
  var lineWidth: CGFloat = 3

  let totalTime: TimeInterval = 30

  init(timeLeft: TimeInterval, size: Int = 24, fontSize: CGFloat, lineWidth: CGFloat) {
    self.endDate = Date().addingTimeInterval(timeLeft)
    _timeLeft = State(initialValue: timeLeft)
    self.size = size
    self.fontSize = fontSize
    self.lineWidth = lineWidth
  }

  var body: some View {
    VStack {
      ZStack {
        ProgressBar(timeLeft: timeLeft, totalTime: totalTime, size: CGSize(width: size, height: size), lineWidth: lineWidth)
        Clock(timeLeft: timeLeft, fontSize: fontSize)
      }
    }
    .onAppear {
      timeLeft = max(0, endDate.timeIntervalSinceNow)
    }
  }
}


struct CountdownView_Previews: PreviewProvider {
  static var previews: some View {
    CountdownView(timeLeft: 14, fontSize: 10, lineWidth: 3)
  }
}
