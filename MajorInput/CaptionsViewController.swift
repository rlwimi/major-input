import UIKit
import Anchorage
import ReactiveCocoa
import ReactiveSwift

final class CaptionsViewController: UIViewController, ViewDowncasting {

  var onTransformerDoubleTap: (() -> Void)?

  fileprivate let captions: [Caption]

  typealias DowncastView = CaptionsView

  /// Offset into the captions where the transformer is anchored.
  fileprivate var transformerAnchor: CGFloat = 60 { // roughly starts things at the title screen (will need revisited, not consistent across years)
    didSet {
      downcastView.setNeedsUpdateConstraints()
    }
  }

  fileprivate var transformerOffset: CGFloat {
    get {
      return transformerY.constant
    }
    set {
      transformerY.constant = newValue
      downcastView.setNeedsUpdateConstraints()
    }
  }

  fileprivate var transformerY: NSLayoutConstraint!

  fileprivate let transformerTap = UITapGestureRecognizer()
  fileprivate let transformerDoubleTap = UITapGestureRecognizer()

  fileprivate let transformerPan = UIPanGestureRecognizer()
  fileprivate let transformerTapDrag = UILongPressGestureRecognizer()

  fileprivate var transformerIsPanning: Bool {
    return transformerIsExtending || transformerIsReanchoring
  }

  fileprivate var transformerIsReanchoring: Bool {
    return transformerTapDrag.state != .possible
  }

  fileprivate var transformerIsExtending: Bool {
    return transformerPan.state != .possible
  }

  fileprivate var transformerIsReeling = false
  fileprivate var isScrollingToCaptionTap = false

  let time: Property<TimeInterval>
  fileprivate let _time: MutableProperty<TimeInterval>

  fileprivate var isExternallyDriven: Bool = false
  var isUserDriven: Bool {
    return
      isExternallyDriven == false &&
        (downcastView.captions.isDragging ||
        (transformerIsPanning && transformerIsReeling == false) ||
        isScrollingToCaptionTap)
  }

  init(captions: [Caption]) {
    self.captions = captions
    _time = MutableProperty(0)
    time = Property(_time)
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func loadView() {
    view = CaptionsView()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    initialize()
    observeCaptionsScrolling()
    observeTransformerPanning()
  }

  override func updateViewConstraints() {
    super.updateViewConstraints()

    let delta = transformerAnchor - transformerOffset
    downcastView.springTop.constant = min(0, delta)
    downcastView.springBottom.constant = max(0, delta)
  }
}

extension CaptionsViewController { // ViewInitializing

  override func configure() {
    downcastView.captions.delegate = self
    downcastView.captions.dataSource = self
    downcastView.captions.registerReusableCell(CaptionCell.self)

    transformerTap.addTarget(self, action: #selector(transformerTapped))

    transformerDoubleTap.numberOfTapsRequired = 2
    transformerDoubleTap.addTarget(self, action: #selector(transformerDoubleTapped))

    transformerPan.addTarget(self, action: #selector(panTransformer(with:)))

    transformerTapDrag.numberOfTapsRequired = 1
    transformerTapDrag.minimumPressDuration = 0
    transformerTapDrag.addTarget(self, action: #selector(tapDragTransformer(with:)))

    transformerTap.require(toFail: transformerDoubleTap)
    transformerTapDrag.require(toFail: transformerDoubleTap)
  }

  override func buildUserInterface() {
    downcastView.transformer.addGestureRecognizer(transformerTap)
    downcastView.transformer.addGestureRecognizer(transformerDoubleTap)
    downcastView.transformer.addGestureRecognizer(transformerPan)
    downcastView.transformer.addGestureRecognizer(transformerTapDrag)
  }

  override func activateDefaultLayout() {
    transformerY = (downcastView.transformer.centerYAnchor == downcastView.captions.topAnchor + transformerAnchor)
  }
}

fileprivate extension CaptionsViewController {
  @objc func transformerTapped() {
    reelTransformerToAnchor(animated: true)
  }

  @objc func transformerDoubleTapped() {
    onTransformerDoubleTap?()
  }

  @objc func panTransformer(with recognizer: UIGestureRecognizer) {
    panTransformer(to: transformerPosition(from: recognizer))
  }

  @objc func tapDragTransformer(with recognizer: UIGestureRecognizer) {
    panTransformer(to: transformerPosition(from: recognizer))
    transformerAnchor = transformerOffset
  }

  func transformerPosition(from recognizer: UIGestureRecognizer) -> CGFloat {
    return recognizer.location(in: downcastView.captions).y - downcastView.captions.contentOffset.y
  }

  func panTransformer(to yPosition: CGFloat) {
    let transformerHeight = downcastView.transformer.bounds.height
    transformerOffset = clamp(yPosition,
                              above: downcastView.bounds.minY + transformerHeight / 2,
                              below: downcastView.bounds.maxY - transformerHeight / 2)
  }

  func clamp(_ position: CGFloat, above lower: CGFloat, below upper: CGFloat, insetBy inset: CGFloat = 0) -> CGFloat {
    let min = lower + inset
    let max = upper - inset
    let clamped = (position...position).clamped(to: (min...max)).lowerBound
    return clamped
  }


  func reelTransformerToAnchor(animated: Bool = false) {
    let captionsOffset = CGPoint(x: downcastView.captions.contentOffset.x,
                                 y: downcastView.captions.contentOffset.y - transformerAnchor + transformerOffset)
    transformerIsReeling = true

    transformerOffset = transformerAnchor
    downcastView.captions.setContentOffset(captionsOffset, animated: animated)

    UIView.animate(
      withDuration: animated ? 0.3 : 0,
      delay: 0,
      options: [.beginFromCurrentState],
      animations: {
        self.view.layoutImmediately()
    },
      completion: { finished in
        self.transformerIsReeling = false
    }
    )
  }
}

fileprivate extension CaptionsViewController {
  func seek(tapped caption: Caption) {
    guard isScrollingToCaptionTap == false
      else { return }
    isScrollingToCaptionTap = true
    scrollCaptions(to: caption.start, animated: true)
    afterSystemAnimation(do: strongify(weak: self) { `self`, _ in
      self.isScrollingToCaptionTap = false
    })
  }
}

extension CaptionsViewController {
  func scrollCaptions(to time: TimeInterval) {
    isExternallyDriven = true
    scrollCaptions(to: time, animated: false)
    isExternallyDriven = false
  }

  fileprivate func scrollCaptions(to time: TimeInterval, animated: Bool) {
    let index = captions.index(for: time)
    let indexPath = IndexPath(row: index, section: 0)
    let captionProgress = CGFloat(time.progress(through: captions[index]))

    guard let layout = downcastView.captions.layoutAttributesForItem(at: indexPath)
      else { fatalError() }
    let itemOffset = layout.frame.minY + captionProgress * layout.frame.height
    let collectionOffset = itemOffset - transformerY.constant

    let target = CGPoint(x: 0, y: collectionOffset)
    downcastView.captions.setContentOffset(target, animated: animated)
  }
}

fileprivate extension CaptionsViewController {
  func observeCaptionsScrolling() {
    DynamicProperty<CGPoint>(object: downcastView.captions, keyPath: #keyPath(UIScrollView.contentOffset))
      .producer
      .take(during: reactive.lifetime)
      .skipNil()
      .observe(on: UIScheduler())
      .startWithValues(strongify(weak: self) { `self`, _ in
        self.captionsDidScroll()
      })
  }

  func observeTransformerPanning() {
    DynamicProperty<CGFloat>(object: transformerY, keyPath: #keyPath(NSLayoutConstraint.constant))
      .producer
      .take(during: reactive.lifetime)
      .skipNil()
      .observe(on: UIScheduler())
      .startWithValues(strongify(weak: self) { `self`, _ in
        self.captionsDidScroll()
      })
  }

  func captionsDidScroll() {
    guard isUserDriven else { return }
    let collectionView = downcastView.captions
    let offset = collectionView.contentOffset.y + transformerY.constant

    guard
      let indexPath = collectionView.indexPathForItem(at: CGPoint(x: 0, y: offset)),
      let cell = collectionView.cellForItem(at: indexPath)
      else { return }

    let caption = captions[indexPath.item]
    let cellProgress = Double((offset - cell.frame.minY) / cell.frame.height)
    let time = caption.start + cellProgress * caption.duration
    _time.value = time
  }
}

extension CaptionsViewController: UICollectionViewDataSource {

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return captions.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell: CaptionCell = collectionView.dequeueReusableCell(indexPath: indexPath)
    let caption = captions[indexPath.row]
    cell.props = CaptionCellProps(text: caption.text)
    return cell
  }
}

extension CaptionsViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    // inject width, leave height to each cell, but a good estimate here helps the scrollbar
    return CGSize(width: collectionView.bounds.size.width, height: 30)
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    seek(tapped: captions[indexPath.item])
  }
}
