import Foundation

extension Collection {

  subscript (safe index: Index) -> Iterator.Element? {
    return indices.contains(index) ? self[index] : nil
  }
}

extension String {
  /// - parameters:
  ///   - substring: A string known to be contained within the instance.
  /// - returns: The position of the end of the substring within the instance, normalized from zero
  ///            to one.
  /// - precondition: The instance contains `substring`.
  func progress(throughRangeOf substring: String) -> Double {
    let range = self.range(of: substring)!
    let substringDistance = distance(from: startIndex, to: range.upperBound)
    let totalDistance = distance(from: startIndex, to: endIndex)
    let progress = Double(substringDistance) / Double(totalDistance)
    return progress
  }
}

extension String {
  var endsInTerminalPoint: Bool {
    guard let last = self.trimmingCharacters(in: .whitespacesAndNewlines).last
      else { return false }
    return String(last).rangeOfCharacter(from: .terminalPunctuation) != nil
  }
}

extension String {
  var isBracketed: Bool {
    let trimmed = self.trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmed.isEmpty == false && trimmed.first! == "[" && trimmed.last! == "]"
  }
}
