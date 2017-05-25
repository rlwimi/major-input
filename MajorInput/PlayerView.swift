import AVFoundation
import UIKit
import Anchorage
import ReactiveCocoa
import ReactiveSwift

final class PlayerView: UIView {

  let overlayToggle = TouchStencilingButton()
  let overlay = UIView()

  let bottomBar = UIView()
  let currentTime = UILabel()
  let totalTime = UILabel()
  let scrubber = UISlider()

  /// Subtly indicates the current time through duration while controls are hidden.
  let progress = UIProgressView(progressViewStyle: .default)

  fileprivate var seeker: PlayerSeeker!

  /// Setter is one-shot.
  var player: AVPlayer? {
    get {
      return playerLayer.player
    }
    set {
      playerLayer.player = newValue
      observePlayer()
    }
  }

  fileprivate var playerLayer: AVPlayerLayer {
    return layer as! AVPlayerLayer
  }

  override static var layerClass: AnyClass {
    return AVPlayerLayer.self
  }

  let showsOverlay: Property<Bool>
  fileprivate let _showsOverlay: MutableProperty<Bool>

  override init(frame: CGRect) {
    _showsOverlay = MutableProperty(true)
    showsOverlay = Property(_showsOverlay)
    super.init(frame: frame)
    initialize()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    bringSubview(toFront: overlayToggle)
  }
}

extension PlayerView { // ViewInitializing
  override func configure() {
    layer.backgroundColor = UIColor.black.cgColor
    overlay.backgroundColor = .clear
    bottomBar.backgroundColor = .gray

    overlayToggle.addTarget(self, action: #selector(toggleOverlay), for: .touchUpInside)
    overlayToggle.stenciledViews = [bottomBar]

    currentTime.textColor = .white
    totalTime.textColor = .white

    currentTime.textAlignment = .center
    totalTime.textAlignment = .center

    progress.trackTintColor = .clear

    scrubber.addTarget(self, action: #selector(scrub), for: .valueChanged)
  }

  override func buildUserInterface() {
    addSubview(progress)
    addSubview(overlay)
    overlay.addSubview(bottomBar)
    bottomBar.addSubview(currentTime)
    bottomBar.addSubview(scrubber)
    bottomBar.addSubview(totalTime)
    addSubview(overlayToggle)
  }

  override func activateDefaultLayout() {
    overlay.edgeAnchors == self.edgeAnchors
    overlayToggle.edgeAnchors == self.edgeAnchors

    progress.horizontalAnchors == self.horizontalAnchors
    progress.bottomAnchor == self.bottomAnchor

    bottomBar.horizontalAnchors == self.horizontalAnchors
    bottomBar.bottomAnchor == self.bottomAnchor
    bottomBar.heightAnchor == 44

    currentTime.centerYAnchor == bottomBar.centerYAnchor
    scrubber.centerYAnchor == bottomBar.centerYAnchor
    totalTime.centerYAnchor == bottomBar.centerYAnchor

    currentTime.widthAnchor == labelWidth
    totalTime.widthAnchor == labelWidth

    currentTime.leadingAnchor == bottomBar.leadingAnchor
    scrubber.leadingAnchor == currentTime.trailingAnchor
    totalTime.leadingAnchor == scrubber.trailingAnchor
    bottomBar.trailingAnchor == totalTime.trailingAnchor
  }
}

extension PlayerView {
  func setShowsOverlay(_ shows: Bool, animated: Bool = false) {
    guard scrubber.isTracking == false else { return }

    if showsOverlay.value == false && shows {
      overlay.isHidden = false
    }
    UIView.animate(
      withDuration: animated ? 0.25 : 0,
      delay: 0,
      options: .beginFromCurrentState,
      animations: {
        self.overlay.alpha = (shows ? 1 : 0)
    },
      completion: { finished in
        if shows == false && finished {
          self.overlay.isHidden = true
        }
    })
    _showsOverlay.value = shows
  }
}

fileprivate extension PlayerView {
  var labelWidth: CGFloat {
    currentTime.text = "XX:XX:XX"
    currentTime.sizeToFit()
    let width = currentTime.bounds.width + 40
    return width
  }

  @objc func toggleOverlay() {
    setShowsOverlay(!showsOverlay.value, animated: true)
  }

  func observePlayer() {
    guard let player = player else { return }

    seeker = PlayerSeeker(player: player)

    player.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 60), queue: DispatchQueue.main, using: strongify(weak: self) { `self`, time in
      self.didObservePlayerTimeUpdate()
    })

    DynamicProperty<Int>(object: player, keyPath: #keyPath(AVPlayer.status))
      .producer
      .take(during: reactive.lifetime)
      .skipNil()
      .uniqueValues()
      .map(AVPlayerStatus.init(rawValue:))
      .skipNil()
      .observe(on: UIScheduler())
      .startWithValues(strongify(weak: self) { `self`, status in
        guard case .readyToPlay = status else { return }
        self.totalTime.text = player.currentItem?.asset.duration.seconds.digitalClockText
      })
  }

  var playbackProgress: Float {
    guard
      let currentTime = player?.currentTime().seconds,
      let duration = player?.currentItem?.duration.seconds
      else { return 0 }

    return Float(currentTime / duration)
  }

  var currentTimeText: String {
    let time = player?.currentTime().seconds ?? 0
    return time.digitalClockText
  }

  func didObservePlayerTimeUpdate() {
    progress.progress = playbackProgress
    if scrubber.isTracking == false {
      scrubber.setValue(playbackProgress, animated: false)
    }
    currentTime.text = currentTimeText
  }

  @objc func scrub() {
    guard
      let player = player, player.status == .readyToPlay,
      let duration = player.currentItem?.duration.seconds,
      let asset = player.currentItem?.asset
      else { return }

    let time = Double(scrubber.value) * duration
    seeker.seek(to: asset.makeTime(with: time))
  }
}
