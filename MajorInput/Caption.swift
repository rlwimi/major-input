import Foundation

struct Caption {
  var start: TimeInterval
  var end: TimeInterval
  var text: String
}

extension Caption {
  init(text: String = "", startTime: TimeInterval = 0, endTime: TimeInterval = 0) {
    self.text = text
    self.start = startTime
    self.end = endTime
  }
}

extension Caption: Equatable {
  static func == (lhs: Caption, rhs: Caption) -> Bool {
    return
      lhs.start == rhs.start &&
      lhs.end == rhs.end &&
      lhs.text == rhs.text
  }
}

extension Caption {
  var middle: TimeInterval {
    return (end + start) / 2
  }

  var duration: TimeInterval {
    return end - start
  }
}

extension Caption {
  mutating func merge(_ other: Caption) {
    self.start = min(self.start, other.start)
    self.end = max(self.end, other.end)
    self.text = [self.text, other.text].joined(separator: " ")
  }

  func merging(_ other: Caption) -> Caption {
    var copy = self
    copy.merge(other)
    return copy
  }
}

extension Array where Element == Caption {
  var sentencifying: [Caption] {
    var sentences: [Caption] = []

    for caption in self {
      if case let .some(last) = sentences.last, last.completesSentence == false {
        sentences[sentences.index(before: sentences.endIndex)] = last.merging(caption)
      } else {
        sentences.append(caption)
      }
    }
    return sentences
  }
}

fileprivate extension Caption {
  /// True unless `text` ends in a terminal point (`[.!?]`) and except for square-bracketed values.
  fileprivate var completesSentence: Bool {
    return text.endsInTerminalPoint || text.isBracketed
  }
}

extension Array where Element == Caption {
  /// Index of the element whose time interval contains `time`. If `time` falls between captions,
  /// return the index of the first caption following `time`, or the index of the last caption for
  /// all `time`s past the end.
  func index(for time: TimeInterval) -> Int {
    precondition(isEmpty == false)
    let index: Int
    if let first = self.index(where: { time < $0.end }) {
      index = first
    } else {
      index = indices.last!
    }
    return index
  }
}
