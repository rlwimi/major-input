import UIKit
import Anchorage

struct FilmstripCellProps {
  var image = UIImage()
}

final class FilmstripCell: UICollectionViewCell {

  var props = FilmstripCellProps() {
    didSet {
      didSetProps()
    }
  }

  let image = UIImageView()

  override init(frame: CGRect) {
    super.init(frame: frame)
    initialize()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  fileprivate func didSetProps() {
    image.image = props.image
  }
}

extension FilmstripCell { // ViewInitializing
  override func configure() {
    didSetProps()
  }

  override func buildUserInterface() {
    contentView.addSubview(image)
  }

  override func activateDefaultLayout() {
    // Respect `thumbnail.size`.
    image.setContentHuggingPriority(UILayoutPriorityRequired, for: .horizontal)
    image.setContentHuggingPriority(UILayoutPriorityRequired, for: .vertical)
    image.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .horizontal)
    image.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)

    image.edgeAnchors == contentView.edgeAnchors
  }
}
