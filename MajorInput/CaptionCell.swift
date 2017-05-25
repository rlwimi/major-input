import UIKit
import Anchorage

struct CaptionCellProps {
  var text = ""
}

final class CaptionCell: UICollectionViewCell {

  var props = CaptionCellProps() {
    didSet {
      didSetProps()
    }
  }

  let caption = UILabel()

  var contentWidth: NSLayoutConstraint!

  override init(frame: CGRect) {
    super.init(frame: frame)
    initialize()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  fileprivate func didSetProps() {
    caption.text = props.text
  }
}

extension CaptionCell { // ViewInitializing
  override func configure() {
    didSetProps()
    caption.numberOfLines = 0
    contentView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 8, right: 16)
}

  override func buildUserInterface() {
    contentView.addSubview(caption)
  }

  override func activateDefaultLayout() {
    // Content will determine height. Minimally hugging prevents unwanted sprawl.
    contentView.heightAnchor == 0 ~ UILayoutPriority(1)

    // Autosizing will inject the width,
    contentWidth = (contentView.widthAnchor == 0)
    // but avoid conflict before that time.
    contentWidth.isActive = false

    caption.edgeAnchors == contentView.layoutMarginsGuide.edgeAnchors
  }
}

extension CaptionCell { // UICollectionViewCell
  override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
    layoutAttributes.frame.size = contentView.systemLayoutSizeFitting(
      layoutAttributes.frame.size,
      withHorizontalFittingPriority: UILayoutPriorityRequired,
      verticalFittingPriority: UILayoutPriority(1)
    )
    contentWidth.constant = layoutAttributes.frame.size.width
    contentWidth.isActive = true
    return layoutAttributes
  }
}
