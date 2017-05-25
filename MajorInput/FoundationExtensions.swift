import AVFoundation
import Foundation

extension CharacterSet {

  /// The set of sentence-terminating punctuation marks.
  static var terminalPunctuation: CharacterSet {
    return CharacterSet(charactersIn: ".!?")
  }
}

extension TimeInterval {
  init(hours: Int = 0, minutes: Int = 0, seconds: Int = 0, milliseconds: Int = 0) {
    let milliseconds = Double(milliseconds) / 1000
    let seconds = Double(seconds)
    let minutes = Double(minutes * 60)
    let hours = Double(hours * 60 * 60)
    self = TimeInterval(hours + minutes + seconds + milliseconds)
  }
}

extension TimeInterval {

  init(for progress: Double, through caption: Caption) {
    self = caption.start + progress * caption.duration
  }

  func progress(through caption: Caption) -> Double {
    if self <= caption.start {
      return 0
    }
    if self >= caption.end {
      return 1
    }
    let progress = (self - caption.start) / caption.duration
    return Double(progress)
  }
}

extension TimeInterval {

  static let MinutesSecondsFormatter: NumberFormatter = {
    let f = NumberFormatter()
    f.maximumFractionDigits = 0
    f.minimumIntegerDigits = 2
    f.maximumIntegerDigits = 2
    return f
  }()

  /// A `String` with the instance formatted as HHH:MM:SS. Minutes and seconds are always present,
  /// but hours is present only when non-zero.
  var digitalClockText: String {
    let seconds = Int(self) % 60
    let minutes = (Int(self) / 60) % 60
    let hours = Int(self) / 3600

    let formatter = TimeInterval.MinutesSecondsFormatter

    let hoursText: String? = (hours < 1 ? nil : "\(hours)")
    let minutesText = formatter.string(from: minutes as NSNumber)
    let secondsText = formatter.string(from: seconds as NSNumber)

    let text = [hoursText, minutesText, secondsText].flatMap { $0 }.joined(separator: ":")
    return text
  }
}
