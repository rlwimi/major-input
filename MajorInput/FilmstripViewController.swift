import UIKit

final class FilmstripViewController: UIViewController, ViewDowncasting {

  typealias DowncastView = UICollectionView

  let layout = UICollectionViewFlowLayout()

  var images: [UIImage] = [] {
    didSet {
      downcastView.reloadDataImmediately()
    }
  }

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    initialize()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func loadView() {
    view = UICollectionView(frame: UIScreen.main.bounds, collectionViewLayout: layout)
  }
}

extension FilmstripViewController { // ViewInitializing

  override func configure() {
    downcastView.backgroundColor = .black
    downcastView.contentInset = .zero
    downcastView.decelerationRate = UIScrollView.DecelerationRate.fast

    downcastView.dataSource = self
    downcastView.registerReusableCell(FilmstripCell.self)
  }

  override func activateDefaultLayout() {
    layout.scrollDirection = .horizontal
    layout.minimumInteritemSpacing = 0
    layout.minimumLineSpacing = 0
  }
}

extension FilmstripViewController: UICollectionViewDataSource {

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return images.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell: FilmstripCell = collectionView.dequeueReusableCell(indexPath: indexPath)
    cell.props = FilmstripCellProps(image: images[indexPath.item])
    return cell
  }
}
