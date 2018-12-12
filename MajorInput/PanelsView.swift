import AVFoundation
import UIKit

import Anchorage

final class PanelsView: UIView,
  UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout {

  enum K {
    static let spacing: CGFloat = 20
    static let numberOfPanels = 6
  }

  let layout: UICollectionViewFlowLayout
  let collectionView: UICollectionView
  var panels: [PanelView] = []

  var url: URL?

  override init(frame: CGRect) {
    layout = UICollectionViewFlowLayout()
    collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
    super.init(frame: frame)
    configure()
    buildUserInterface()
    activateDefaultLayout()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func configure() {
    collectionView.registerReusableCell(UICollectionViewCell.self)
    collectionView.dataSource = self
    collectionView.delegate = self
  }

  override func buildUserInterface() {
    addSubview(collectionView)
  }

  override func activateDefaultLayout() {
    collectionView.edgeAnchors == layoutMarginsGuide.edgeAnchors
    layout.sectionInset = [.top: K.spacing, .bottom: K.spacing]
    layout.minimumLineSpacing = K.spacing
  }

  func render(_ captions: [Caption]) {
    guard let url = url else {
      return
    }

    for caption in captions {
      let panel = PanelView()
      panel.layoutMargins = .init(uniform: 8)
      panels.append(panel)
      let asset = AVAsset(url: url)
      let item = AVPlayerItem(asset: asset)
      let player = AVPlayer(playerItem: item)
      player.isMuted = true
      panel.looper.downcastLayer.player = player
      panel.render(caption)
    }

    collectionView.reloadData()
  }

  // MARK: - UICollectionViewDataSource

  func collectionView(_ collectionView: UICollectionView,
                      numberOfItemsInSection section: Int) -> Int {
    return panels.count
  }

  func collectionView(_ collectionView: UICollectionView,
                      cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

    let cell: UICollectionViewCell = collectionView.dequeueReusableCell(indexPath: indexPath)
    cell.layoutMargins = .zero
    return cell
  }



  // MARK: - UICollectionViewDelegate

  func collectionView(_ collectionView: UICollectionView,
                      willDisplay cell: UICollectionViewCell,
                      forItemAt indexPath: IndexPath) {

    let panel = panels[indexPath.item]
    cell.addSubview(panel)
    panel.edgeAnchors == cell.layoutMarginsGuide.edgeAnchors
  }

  func collectionView(_ collectionView: UICollectionView,
                      didEndDisplaying cell: UICollectionViewCell,
                      forItemAt indexPath: IndexPath) {

    let panel = panels[indexPath.item]
    panel.removeFromSuperview()
  }

  // MARK: - UICollectionViewDelegateFlowLayout

  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {

    let itemsPerRow = 2
    let rowsPerColumn = panels.count / itemsPerRow
    let usedHorizontalSpace = layout.sectionInset.horizontalTotal + CGFloat(itemsPerRow - 1) * K.spacing
    let width = (collectionView.frame.width - usedHorizontalSpace) / CGFloat(itemsPerRow)
    let usedVerticalSpace = layout.sectionInset.verticalTotal + CGFloat(rowsPerColumn - 1) * layout.minimumLineSpacing
    let height = (collectionView.frame.height - usedVerticalSpace) / CGFloat(rowsPerColumn)
    return CGSize(width: width, height: height)
  }
}
