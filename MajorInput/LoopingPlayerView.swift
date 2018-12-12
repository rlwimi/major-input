import AVFoundation
import UIKit

import Anchorage

final class LoopingPlayerView: UIView, LayerDowncasting {

  typealias DowncastLayer = AVPlayerLayer

  private var loopObservation: Any?
  private var aspect = NSLayoutConstraint()

  override class var layerClass: AnyClass {
    return DowncastLayer.self
  }

  private var currentAsset: AVAsset? {
    return downcastLayer.player?.currentItem?.asset
  }

  func render(_ caption: Caption) {
    guard let asset = currentAsset else {
      return
    }
    let startOfLoop = asset.makeTime(with: caption.start)
    let endOfLoop = asset.makeTime(with: caption.end)

    loopObservation = downcastLayer.player?.addBoundaryTimeObserver(
      forTimes: [NSValue(time: endOfLoop)],
      queue: DispatchQueue.main) { [weak self] in

        self?.downcastLayer.player?.seek(to: startOfLoop)
    }

    downcastLayer.player?.seek(to: startOfLoop)
//    downcastLayer.player?.play()

    let size = asset.videoTrack.naturalSize
    let aspectRatio = size.width / size.height

    aspect.isActive = false
    aspect = (widthAnchor == aspectRatio * heightAnchor)
  }
}
