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
    image.setContentHuggingPriority(UILayoutPriority.required, for: .horizontal)
    image.setContentHuggingPriority(UILayoutPriority.required, for: .vertical)
    image.setContentCompressionResistancePriority(UILayoutPriority.required, for: .horizontal)
    image.setContentCompressionResistancePriority(UILayoutPriority.required, for: .vertical)

    image.edgeAnchors == contentView.edgeAnchors
  }
}
