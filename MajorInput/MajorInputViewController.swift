import UIKit
import AVFoundation
import Anchorage
import ReactiveCocoa
import ReactiveSwift

final class MajorInputViewController: UIViewController, ViewDowncasting {

  typealias Dependencies = HasSessionsService & HasDownloadsService
  typealias DowncastView = MajorInputView

  fileprivate let session: Session
  fileprivate let captions: [Caption]

  fileprivate let filmstripViewController = FilmstripViewController()
  fileprivate let captionsViewController: CaptionsViewController

  fileprivate var playerView: PlayerView {
    return downcastView.player
  }

  fileprivate var filmstripCollectionView: UICollectionView {
    return filmstripViewController.downcastView
  }

  fileprivate var captionsCollectionView: UICollectionView {
    return captionsViewController.downcastView.captions
  }

  fileprivate let asset: AVAsset
  fileprivate let player: AVPlayer
  fileprivate var seeker: PlayerSeeker!
  fileprivate var time: TimeInterval {
    return player.currentTime().seconds
  }

  /// Simplify filmstrip by disabling during image generation.
  fileprivate var filmstripEnabled = false

  fileprivate var filmstripHeight: NSLayoutConstraint!
  fileprivate let filmstripCellWidth: CGFloat = 96

  /// Offset into the filmstrip aligning the current caption's image (center)
  fileprivate var filmstripTimeIndicatorOffset: CGFloat = 0

  override var prefersStatusBarHidden: Bool {
    return playerView.showsOverlay.value == false
  }

  init(session: Session, dependencies: Dependencies) {
    self.session = session

    guard case .downloaded(let url) = dependencies.downloadsService.status(for: session).value
      else { fatalError() }

    asset = AVAsset(url: url)
    player = AVPlayer(playerItem: AVPlayerItem(asset: asset))
    captions = dependencies.sessionsService.captions(for: session)
    captionsViewController = CaptionsViewController(captions: captions)

    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func loadView() {
    view = MajorInputView(frame: UIScreen.main.bounds)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    initialize()
    loadVideo()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if player.status == .readyToPlay {
      pushInitialTime()
    }
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    // Captions need to cover the filmstrip time indicator. The player should cover the filmstrip
    // and its time indicator to support the filmstrip's animated appearance. The button for
    // initial transfer of playback controls control must be above the player.
    downcastView.bringSubview(toFront: downcastView.filmstripTimeIndicator)
    downcastView.bringSubview(toFront: captionsViewController.downcastView)
    downcastView.bringSubview(toFront: downcastView.player)

    let filmstrip = filmstripViewController.downcastView
    filmstripTimeIndicatorOffset = filmstrip.frame.minX + 2 * filmstripCellWidth

    downcastView.filmstripTimeIndicatorCenter.constant = filmstripTimeIndicatorOffset
  }
}

extension MajorInputViewController { // ViewInitializing
  override func configure() {
    title = "\(session.conference.rawValue) \(session.year) | \(session.number) | \(session.title)"
    automaticallyAdjustsScrollViewInsets = false

    playerView.setShowsOverlay(false)

    downcastView.filmstripTimeIndicator.isHidden = true

    // Disable scrolling until inductions are configured after player is `readyToPlay`
    filmstripCollectionView.isScrollEnabled = false
    captionsCollectionView.isScrollEnabled = false

    captionsViewController.onTransformerDoubleTap = strongify(weak: self) { `self`, _ in
      self.togglePlayback()
    }
  }

  override func buildUserInterface() {
    addChildViewController(filmstripViewController)
    view.addSubview(filmstripViewController.view)
    filmstripViewController.didMove(toParentViewController: self)

    addChildViewController(captionsViewController)
    view.addSubview(captionsViewController.view)
    captionsViewController.didMove(toParentViewController: self)
  }

  override func activateDefaultLayout() {

    let size = asset.videoTrack.naturalSize
    let aspectRatio = size.width / size.height

    playerView.widthAnchor == aspectRatio * playerView.heightAnchor

    let filmstrip = filmstripViewController.downcastView
    filmstrip.edgeAnchors == downcastView.filmstripLayoutGuide.edgeAnchors
    filmstripHeight = (filmstripViewController.downcastView.heightAnchor == 0)

    captionsViewController.downcastView.edgeAnchors == downcastView.captionsLayoutGuide.edgeAnchors
  }
}

fileprivate extension MajorInputViewController {
  func loadVideo() {
    DynamicProperty<Int>(object: player, keyPath: #keyPath(AVPlayer.status))
      .producer
      .take(during: reactive.lifetime)
      .skipNil()
      .map(AVPlayerStatus.init(rawValue:))
      .skipNil()
      .observe(on: UIScheduler())
      .startWithValues(strongify(weak: self) { `self`, status in
        guard case .readyToPlay = status else { return }
        self.seeker = PlayerSeeker(player: self.player)
        self.generateThumbnails()
        self.configureInduction()
        self.pushInitialTime()
      })

    playerView.player = player
  }

  func generateThumbnails() {
    let times = captions.map { $0.middle }
    var thumbnails: [UIImage] = []
    asset.images(for: times, size: CGSize(width: filmstripCellWidth, height: filmstripCellWidth))
      .observe(on: UIScheduler())
      .start(
        Observer(
          value: strongify(weak: self) { `self`, images in
            thumbnails = images
          },
          completed: strongify(weak: self) { `self`, _ in
            self.didGenerateThumbnails(thumbnails)
          }
        )
    )
  }

  func didGenerateThumbnails(_ thumbnails: [UIImage]) {
    // Configure filmstrip with thumbnail size, animating appearance.
    if let sample = thumbnails[safe: 0] {
      assert(filmstripHeight.constant == 0)
      // UIKit "corrects" a negative contentOffset in layout, setting it to zero. We'll undo this.
      let captionsOffset = captionsCollectionView.contentOffset

      // Inflate filmstrip, hide under player
      filmstripHeight.constant = sample.size.height
      downcastView.filmstripTop.constant = -sample.size.height
      filmstripViewController.layout.itemSize = sample.size
      downcastView.layoutImmediately()

      // Slide filmstrip into place.
      downcastView.filmstripTimeIndicator.isHidden = false
      UIView.animate(
        withDuration: 0.25,
        animations: {
          self.downcastView.filmstripTop.constant = 0
          self.downcastView.layoutImmediately()
          self.captionsCollectionView.contentOffset = captionsOffset
      })
    }

    // Inject content into filmstrip, reload, and sync with time.
    filmstripViewController.images = thumbnails
    filmstripEnabled = true
    updateFilmstrip(with: time)
  }

  func configureInduction() {
    // The captions collection and transformer position come together to select a cell representing
    // a caption time range, with the offset from the cell's beginning interpolated into the time
    // range.
    //
    // While either collection is interacted (with scroll/tap taking precedence over deceleration),
    // the other collection and the player should sync.
    //
    // When the player is playing, the collections should sync.

    filmstripCollectionView.isScrollEnabled = true
    captionsCollectionView.isScrollEnabled = true

    observeCaptionsTime()
    observeFilmstripScrolling()
    observePlayerPlaying()
  }

  func observeCaptionsTime() {
    captionsViewController.time
      .producer
      .take(during: reactive.lifetime)
      .observe(on: UIScheduler())
      .startWithValues(strongify(weak: self) { `self`, time in
        self.captionsDidUpdate(time)
      })
  }

  func observeFilmstripScrolling() {
    DynamicProperty<CGPoint>(object: filmstripViewController.downcastView, keyPath: #keyPath(UIScrollView.contentOffset))
      .producer
      .take(during: reactive.lifetime)
      .skipNil()
      .observe(on: UIScheduler())
      .startWithValues(strongify(weak: self) { `self`, _ in
        self.filmstripDidScroll()
      })
  }

  func observePlayerPlaying() {
    player.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 60), queue: DispatchQueue.main, using: strongify(weak: self) { `self`, time in
      self.didObservePlayerTimeUpdate()
    })
  }

  /// Empirically-determined (quite hastily) time in which a WWDC session's intro slide is in-frame.
  var initialTime: TimeInterval {
    if let year = Int(session.year), year >= 2015 {
      return 21
    } else {
      return 15
    }
  }

  func pushInitialTime() {
    updatePlayer(with: initialTime)
  }

  func didObservePlayerTimeUpdate() {
    // Remember: periodic observers do not fire unless player is playing (rate > 0).
    if captionsViewController.isUserDriven == false && filmstripCollectionView.isDragging == false {
      pushTimeFromPlayer()
    }
  }

  func pushTimeFromPlayer() {
    self.captionsViewController.scrollCaptions(to: time)
    self.updateFilmstrip(with: time)
  }

  func captionsDidUpdate(_ time: TimeInterval) {
    if playerView.showsOverlay.value {
      playerView.setShowsOverlay(false, animated: true)
    }
    updatePlayer(with: time)
    updateFilmstrip(with: time)
  }

  func filmstripDidScroll() {
    guard filmstripCollectionView.isDragging && captionsViewController.isUserDriven == false
      else { return }

    if playerView.showsOverlay.value {
      playerView.setShowsOverlay(false, animated: true)
    }
    pushTimeFromFilmstrip()
  }

  func pushTimeFromFilmstrip() {
    let offset = filmstripCollectionView.contentOffset.x + filmstripTimeIndicatorOffset

    guard
      let indexPath = filmstripCollectionView.indexPathForItem(at: CGPoint(x: offset, y: 0)),
      let cell = filmstripCollectionView.cellForItem(at: indexPath)
      else { return }

    let progress = Double((offset - cell.frame.minX) / cell.frame.width)
    let caption = captions[indexPath.item]
    let time = TimeInterval(for: progress, through: caption)

    updatePlayer(with: time)
    captionsViewController.scrollCaptions(to: time)
  }

  func updatePlayer(with time: TimeInterval) {
    seeker.seek(to: asset.makeTime(with: time))
  }

  func updateFilmstrip(with time: TimeInterval, animated: Bool = false) {
    guard filmstripEnabled else { return }

    let index = captions.index(for: time)
    let indexPath = IndexPath(row: index, section: 0)
    let captionProgress = CGFloat(time.progress(through: captions[index]))

    guard let layout = filmstripCollectionView.layoutAttributesForItem(at: indexPath)
      else { return }

    let offset = layout.frame.minX + captionProgress * layout.frame.width - filmstripTimeIndicatorOffset

    filmstripCollectionView.setContentOffset(CGPoint(x: offset, y: 0), animated: animated)
  }

  func togglePlayback() {
    let style: TransformerView.AntennaStyle
    if player.rate > 0 {
      player.pause()
      style = .play
    } else {
      player.play()
      style = .pause
    }
    captionsViewController.downcastView.transformer.style = style
  }
}
