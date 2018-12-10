import UIKit
import Anchorage

final class CaptionsView: UIView {

  let captions: UICollectionView
  let captionsLayout: UICollectionViewFlowLayout

  let transformer = TransformerView()

  let spring = UIView()

  var springTop: NSLayoutConstraint!
  var springBottom: NSLayoutConstraint!

  override init(frame: CGRect) {
    captionsLayout = UICollectionViewFlowLayout()
    captions = UICollectionView(frame: .zero, collectionViewLayout: captionsLayout)
    super.init(frame: frame)
    initialize()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension CaptionsView { // ViewInitializing
  override func configure() {
    captions.backgroundColor = .white
    captions.contentInset = .zero
    captions.showsVerticalScrollIndicator = false
    captions.decelerationRate = .fast

    captionsLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
    captionsLayout.minimumInteritemSpacing = 0
    captionsLayout.minimumLineSpacing = 0

    spring.backgroundColor = .systemTintColor
}

  override func buildUserInterface() {
    addSubview(captions)
    addSubview(spring)
    addSubview(transformer)
  }

  override func activateDefaultLayout() {
    captions.verticalAnchors == self.verticalAnchors
    // transformer vertical layout is managed

    captions.leadingAnchor == leadingAnchor
    transformer.leadingAnchor == captions.trailingAnchor
    transformer.trailingAnchor == trailingAnchor

    springTop = (spring.topAnchor == transformer.centerYAnchor)
    springBottom = (spring.bottomAnchor == transformer.centerYAnchor)
    spring.trailingAnchor == self.trailingAnchor
    spring.widthAnchor == 4
  }
}
