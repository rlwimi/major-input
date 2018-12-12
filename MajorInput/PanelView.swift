import UIKit

import Anchorage

final class PanelView: UIView {

  let looper = LoopingPlayerView()
  let caption = UILabel()

  override init(frame: CGRect) {

    super.init(frame: frame)
    configure()
    buildUserInterface()
    activateDefaultLayout()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func configure() {
    caption.numberOfLines = 0
    caption.textColor = .yellow
  }

  override func buildUserInterface() {
    addSubview(looper)
    addSubview(caption)
  }

  override func activateDefaultLayout() {
    looper.topAnchor == self.topAnchor
    caption.topAnchor <= looper.bottomAnchor + 8
    caption.topAnchor == looper.bottomAnchor + 8 ~ .high
    caption.bottomAnchor <= layoutMarginsGuide.bottomAnchor

    looper.horizontalAnchors == self.horizontalAnchors
    caption.horizontalAnchors == layoutMarginsGuide.horizontalAnchors

    caption.setContentHuggingPriority(.required, for: .vertical)
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    // In case of overlap...
    bringSubviewToFront(caption)
  }

  func render(_ caption: Caption) {
    looper.render(caption)
    self.caption.text = caption.text
  }
}
