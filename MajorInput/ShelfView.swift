import UIKit
import Anchorage

final class ShelfView: UIView {

  let collection: UICollectionView
  let layout: UICollectionViewFlowLayout

  override init(frame: CGRect) {
    layout = UICollectionViewFlowLayout()
    collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
    super.init(frame: frame)
    initialize()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension ShelfView { // ViewInitializing

  override func configure() {
    collection.backgroundColor = .white
    collection.contentInset = .zero

    layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
    layout.minimumInteritemSpacing = 0
    layout.minimumLineSpacing = 0
  }

  override func buildUserInterface() {
    addSubview(collection)
  }

  override func activateDefaultLayout() {
    collection.edgeAnchors == safeAreaLayoutGuide.edgeAnchors
  }
}
