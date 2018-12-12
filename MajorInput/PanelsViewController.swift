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

    let page = Array(captions[11...16])

    downcastView.render(page)
  }
}
