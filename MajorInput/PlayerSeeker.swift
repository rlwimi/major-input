import AVFoundation

final class PlayerSeeker {

  enum defaults {
    static let tolerance = CMTime(seconds: 0.5, preferredTimescale: 60)
  }

  let player: AVPlayer
  let tolerance: CMTime

  /// player is currently seeking to this time
  fileprivate var seeking: CMTime?

  var isSeeking: Bool {
    return seeking != nil
  }

  /// The most recent target for seek. When set, this will start a new seek when no seek is
  /// currently in progress. When set, if a seek is currently in progress, a new seek will start at
  /// the current seek's completion.
  fileprivate var target: CMTime? {
    didSet {
      guard let target = target, isSeeking == false else { return }
      _seek(to: target)
    }
  }

  fileprivate var isDoneSeeking: Bool {
    return seeking == target
  }

  init(player: AVPlayer, tolerance: CMTime = defaults.tolerance) {
    self.player = player
    self.tolerance = tolerance
  }

  func seek(to time: CMTime) {
    target = time
  }

  fileprivate func _seek(to time: CMTime) {
    seeking = time
    player.seek(to: time, toleranceBefore: tolerance, toleranceAfter: tolerance, completionHandler: strongify(weak: self) { `self`, _ in
      if let target = self.target, self.isDoneSeeking == false {
        self._seek(to: target)
      } else {
        self.seeking = nil
        self.target = nil
      }
    })
  }
}
