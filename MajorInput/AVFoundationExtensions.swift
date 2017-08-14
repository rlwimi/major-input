import AVFoundation
import UIKit
import ReactiveSwift
import Result

extension AVAsset {
  func images(for times: [TimeInterval], size: CGSize) -> SignalProducer<[UIImage], NoError> {
    return SignalProducer(strongify(weak: self) { `self`, observer, disposable in
      let generator = AVAssetImageGenerator(asset: self)
      generator.maximumSize = size

      let requestedTimes = times.map { NSValue(time: self.makeTime(with: $0)) }
      var generatingTimes = requestedTimes
      var frames: [NSValue: UIImage] = [:]

      generator.generateCGImagesAsynchronously(forTimes: requestedTimes) { requestedTime, image, actualTime, result, error in
        let time = NSValue(time: requestedTime)

        guard case .succeeded = result, let cgImage = image, let index = generatingTimes.index(of: time)
          else { fatalError() }

        frames[time] = UIImage(cgImage: cgImage)
        generatingTimes.remove(at: index)
        observer.send(value: requestedTimes.flatMap { frames[$0] })
        if generatingTimes.isEmpty {
          observer.sendCompleted()
        }
      }
    })
  }

  /// Convenience accessor when assuming a single video track is available
  var videoTrack: AVAssetTrack {
    guard let videoTrack = tracks.first(where: { $0.mediaType == .video })
      else { fatalError("Video track unavailable for asset: \(String(reflecting: self))") }
    return videoTrack
  }

  func makeTime(with interval: TimeInterval) -> CMTime {
    let time = CMTime(seconds: interval, preferredTimescale: self.videoTrack.naturalTimeScale)
    return time
  }
}
