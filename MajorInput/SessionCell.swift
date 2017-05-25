import UIKit
import Anchorage
import Haneke
import ReactiveSwift

final class SessionCell: UICollectionViewCell {

  let action = UIButton(type: .system)
  let progress = UIProgressView()
  let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)

  let title = UILabel()
  let image = UIImageView()
  let tags = UILabel()
  let focus = UILabel()
  let detail = UILabel()
  let separator = UIView()

  var contentWidth: NSLayoutConstraint!

  fileprivate var onActionTap: (() -> Void)?

  override init(frame: CGRect) {
    super.init(frame: frame)
    initialize()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configure(with session: Session, downloadStatus: Property<DownloadStatus>, onActionTap: @escaping () -> Void) {
    self.onActionTap = onActionTap

    image.backgroundColor = .black
    image.setImage(from: session.image)

    title.text = "\(session.number): \(session.title)"
    detail.text = session.description

    let tagTexts: [String?] = [session.durationText, session.track.rawValue, session.year]
    tags.text = tagTexts.flatMap({ $0 }).joined(separator: "   ")

    focus.text = "\(session.focuses.map({ $0.rawValue }).joined(separator: "  |  "))"

    downloadStatus
      .producer
      .take(until: reactive.prepareForReuse)
      .startWithValues(strongify(weak: self) { `self`, status in
        self.configure(with: status)
    })
  }

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

  override func prepareForReuse() {
    super.prepareForReuse()
    image.hnk_cancelSetImage()
    image.image = nil
  }
}

extension SessionCell { // ViewInitializing

  override func configure() {
    contentView.backgroundColor = .white

    detail.numberOfLines = 0

    title.font = UIFont.boldSystemFont(ofSize: 32)
    title.adjustsFontSizeToFitWidth = true

    title.textColor = UIColor(white: 34.0/255.0, alpha: 1)
    detail.textColor = UIColor(white: 34.0/255.0, alpha: 1)
    tags.textColor = .lightGray
    focus.textColor = .lightGray

    action.layer.borderColor = UIColor.systemTintColor.cgColor
    action.layer.borderWidth = 1
    action.layer.cornerRadius = 4
    action.layer.masksToBounds = true
    action.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
    action.addTarget(self, action: #selector(tappedAction), for: .touchUpInside)

    progress.progressTintColor = .systemTintColor
    progress.trackTintColor = .clear

    progress.layer.cornerRadius = 4
    progress.layer.masksToBounds = true

    separator.backgroundColor = UIColor(white: 0, alpha: 0.25)
  }

  override func buildUserInterface() {
    contentView.addSubview(title)
    contentView.addSubview(image)
    contentView.addSubview(tags)
    contentView.addSubview(focus)
    contentView.addSubview(detail)
    contentView.addSubview(progress)
    contentView.addSubview(action)
    contentView.addSubview(spinner)
    contentView.addSubview(separator)
  }

  override func activateDefaultLayout() {
    // Content will determine height. Minimally hugging prevents unwanted sprawl.
    contentView.heightAnchor == 0 ~ UILayoutPriority(2)

    // Autosizing will inject the width,
    contentWidth = (contentView.widthAnchor == 0)
    // but avoid conflict before that time.
    contentWidth.isActive = false

    // known aspect ratio = 734/413
    image.widthAnchor == 300
    image.heightAnchor == 169

    // leading column's vertical layout
    title.topAnchor == contentView.topAnchor + 20
    image.topAnchor == title.bottomAnchor + 20
    image.bottomAnchor <= contentView.bottomAnchor - 20

    // trailing column's vertical layout
    tags.topAnchor  == title.bottomAnchor + (20 - (tags.font.ascender - tags.font.capHeight))
    focus.topAnchor == tags.bottomAnchor + 8
    detail.topAnchor == focus.bottomAnchor + 8
    detail.bottomAnchor <= contentView.bottomAnchor - 20

    // horizontal layout
    title.leadingAnchor == contentView.leadingAnchor + 20
    title.trailingAnchor == contentView.trailingAnchor - 20

    image.leadingAnchor == contentView.leadingAnchor + 20

    tags.leadingAnchor == image.trailingAnchor + 20
    tags.trailingAnchor == contentView.trailingAnchor - 20

    focus.leadingAnchor == image.trailingAnchor + 20
    focus.trailingAnchor == contentView.trailingAnchor - 20

    detail.leadingAnchor == image.trailingAnchor + 20
    detail.trailingAnchor == contentView.trailingAnchor - 20

    // action
    action.firstBaselineAnchor == tags.firstBaselineAnchor
    action.trailingAnchor == contentView.trailingAnchor - 20

    progress.edgeAnchors == action.edgeAnchors
    // ^^^ will vertically squeeze button, so...
    action.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)

    spinner.centerYAnchor == action.centerYAnchor
    spinner.trailingAnchor == action.leadingAnchor - 8

    // separator
    separator.horizontalAnchors == contentView.horizontalAnchors + 20
    separator.heightAnchor == (1 / UIScreen.main.scale)
    separator.bottomAnchor == contentView.bottomAnchor
  }
}

fileprivate extension SessionCell {
  func configure(with status: DownloadStatus) {
    let enabled = UIView.areAnimationsEnabled
    UIView.setAnimationsEnabled(false) // Otherwise, UIKit animates title changes for `.system` buttons.
    switch status {
    case .remote:
      action.setTitle("DOWNLOAD", for: .normal)
      action.tintColor = .systemTintColor
      action.layer.borderColor = UIColor.systemTintColor.cgColor
      progress.progress = 0
      spinner.stopAnimating()
    case .downloading(let progress):
      action.setTitle("CANCEL", for: .normal)
      action.tintColor = .black
      action.layer.borderColor = UIColor.black.cgColor
      self.progress.progress = progress // DOH!
      spinner.startAnimating()
    case .downloaded:
      action.setTitle("DELETE", for: .normal)
      action.tintColor = .red
      action.layer.borderColor = UIColor.red.cgColor
      progress.progress = 0
      spinner.stopAnimating()
    }
    contentView.layoutImmediately()
    UIView.setAnimationsEnabled(enabled)
  }

  @objc func tappedAction() {
    onActionTap?()
  }
}
