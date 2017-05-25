import Anchorage
import UIKit

final class MajorInputView: UIView {

  let player = PlayerView()
  let filmstripLayoutGuide = UILayoutGuide(identifier: "filmstrip")
  let captionsLayoutGuide = UILayoutGuide(identifier: "captions")

  let filmstripTimeIndicator = UIView()
  var filmstripTimeIndicatorCenter: NSLayoutConstraint!

  var filmstripTop: NSLayoutConstraint!

  override init(frame: CGRect) {
    super.init(frame: frame)
    initialize()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension MajorInputView { // ViewInitializing
  override func configure() {
    backgroundColor = .white
    filmstripTimeIndicator.backgroundColor = .systemTintColor
  }

  override func buildUserInterface() {
    addSubview(player)
    addLayoutGuide(filmstripLayoutGuide)
    addLayoutGuide(captionsLayoutGuide)
    addSubview(filmstripTimeIndicator)
  }

  override func activateDefaultLayout() {
    player.horizontalAnchors == self.horizontalAnchors
    filmstripLayoutGuide.horizontalAnchors == self.horizontalAnchors
    captionsLayoutGuide.horizontalAnchors == self.horizontalAnchors

    player.topAnchor == self.topAnchor
    filmstripLayoutGuide.topAnchor == player.bottomAnchor

    filmstripTop = (filmstripLayoutGuide.topAnchor == player.bottomAnchor)
    captionsLayoutGuide.topAnchor == filmstripLayoutGuide.bottomAnchor
    captionsLayoutGuide.bottomAnchor == self.bottomAnchor

    filmstripTimeIndicator.widthAnchor == filmstripTimeIndicator.heightAnchor
    filmstripTimeIndicator.widthAnchor == 16
    filmstripTimeIndicator.centerYAnchor == filmstripLayoutGuide.bottomAnchor
    filmstripTimeIndicator.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 4))

    filmstripTimeIndicatorCenter = (filmstripTimeIndicator.centerXAnchor == filmstripLayoutGuide.leadingAnchor)
  }
}
