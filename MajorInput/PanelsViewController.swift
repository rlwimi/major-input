import AVFoundation
import UIKit

final class PanelsViewController: UIViewController,
ViewDowncasting {

  typealias DowncastView = PanelsView
  typealias Dependencies = HasSessionsService & HasDownloadsService

  private let dependencies: Dependencies

  private let session: Session
  private let captions: [Caption]

  init(session: Session, dependencies: Dependencies) {
    self.session = session
    self.dependencies = dependencies
    self.captions = dependencies.sessionsService.captions(for: session)

    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - UIViewController

  override func loadView() {
    view = PanelsView(frame: UIScreen.main.bounds)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.layoutMargins = .zero
    downcastView.collectionView.contentInsetAdjustmentBehavior = .never

    guard case let .downloaded(url) = dependencies.downloadsService.status(for: session).value else {
      fatalError()
    }

    downcastView.url = url

    let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeLeft))
    swipeLeft.direction = .left
    let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeRight))
    swipeRight.direction = .right

    downcastView.addGestureRecognizer(swipeLeft)
    downcastView.addGestureRecognizer(swipeRight)

    render()
  }

  // MARK: - private

  private var panelsPerPage = 6
  private var currentPage = 0

  private var nextPage: Int? {
    let nextPage = currentPage + 1
    if captions.indices.contains(nextPage * panelsPerPage) {
      return nextPage
    } else {
      return nil
    }
  }

  private var previousPage: Int? {
    let previousPage = currentPage - 1
    if captions.indices.contains(previousPage * panelsPerPage) {
      return previousPage
    } else {
      return nil
    }
  }

  private func render() {
    guard let lastCaptionsIndex = captions.indices.last else {
      return
    }
    let first = currentPage * panelsPerPage
    let last = min(first + panelsPerPage, lastCaptionsIndex)
    let page = Array(captions[first..<last])
    downcastView.render(page)
  }

  @objc private func didSwipeLeft() {
    guard let nextPage = nextPage else {
      return
    }
    currentPage = nextPage
    render()
  }

  @objc private func didSwipeRight() {
    guard let previousPage = previousPage else {
      return
    }
    currentPage = previousPage
    render()
  }
}
