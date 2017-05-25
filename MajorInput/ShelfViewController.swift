import UIKit
import SwiftyJSON

final class ShelfViewController: UIViewController, ViewDowncasting {

  typealias Dependencies = HasSessionsService & HasDownloadsService
  typealias DowncastView = ShelfView

  var onSelectSession: ((Session) -> Void)?

  fileprivate var sessions: [Session] = [] {
    didSet {
      guard isViewLoaded else { return }
      downcastView.collection.reloadData()
      downcastView.collection.layoutImmediately()
    }
  }

  fileprivate let downloadsService: DownloadsService

  init(dependencies: Dependencies) {
    sessions = dependencies.sessionsService.sessions
    downloadsService = dependencies.downloadsService
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func loadView() {
    view = ShelfView(frame: UIScreen.main.bounds)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    initialize()
  }
}

extension ShelfViewController { // ViewInitializing
  override func configure() {
    title = "MajorInput"
    automaticallyAdjustsScrollViewInsets = false
    
    downcastView.collection.dataSource = self
    downcastView.collection.delegate = self
    downcastView.collection.registerReusableCell(SessionCell.self)
  }
}

extension ShelfViewController: UICollectionViewDataSource {

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return sessions.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let session = sessions[indexPath.item]
    let status = downloadsService.status(for: session)
    let cell: SessionCell = collectionView.dequeueReusableCell(indexPath: indexPath)
    cell.configure(
      with: session,
      downloadStatus: status,
      onActionTap: strongify(weak: self) { `self`, _ in
        switch status.value {
        case .remote:
          self.downloadsService.downloadVideo(for: session)
        case .downloading(_):
          self.downloadsService.cancelDownload(for: session)
        case .downloaded:
          self.downloadsService.deleteDownload(for: session)
        }
    })
    return cell
  }
}

extension ShelfViewController: UICollectionViewDelegateFlowLayout {

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    // inject width, leave height to each cell, but a good estimate here helps the scrollbar
    return CGSize(width: collectionView.bounds.size.width, height: 360)
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let session = sessions[indexPath.item]
    let status = downloadsService.status(for: session)
    if case .remote = status.value {
      downloadsService.downloadVideo(for: session)
    } else if case .downloaded(_) = status.value {
      onSelectSession?(session)
    }
  }
}
