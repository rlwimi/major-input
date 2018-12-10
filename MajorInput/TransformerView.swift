import UIKit
import Anchorage

final class TransformerView: UIView {

  enum AntennaStyle {
    case play
    case pause
  }

  let icon = TransformerIcon()

  fileprivate let body = UIView()

  fileprivate let indicator = CAShapeLayer()
  var style: AntennaStyle = .play {
    didSet {
      layer.setNeedsLayout()
    }
  }
  fileprivate var antenna: UIBezierPath {
    // A play or pause button. Play button is a triangle half of a 16pt square, a 12x24 area.
    let minY = body.frame.midY - 12
    let maxY = body.frame.midY + 12
    let maxX = body.frame.minX - 1
    let minX = maxX - 12
    let p = UIBezierPath()
    switch style {
    case .play:
      p.move(to: CGPoint(x: maxX, y: body.frame.midY))
      // 16 / sqrt(2) ~= 12
      p.addLine(to: CGPoint(x: minX, y: minY))
      p.addLine(to: CGPoint(x: minX, y: maxY))
      p.close()
    case .pause:
      p.move(to: CGPoint(x: minX, y: minY))
      p.addLine(to: CGPoint(x: minX, y: maxY))
      p.addLine(to: CGPoint(x: minX + 3, y: maxY))
      p.addLine(to: CGPoint(x: minX + 3, y: minY))
      p.close()
      p.move(to: CGPoint(x: minX + 7, y: minY))
      p.addLine(to: CGPoint(x: minX + 7, y: maxY))
      p.addLine(to: CGPoint(x: minX + 10, y: maxY))
      p.addLine(to: CGPoint(x: minX + 10, y: minY))
      p.close()
      break
    }
    return p
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    initialize()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSublayers(of layer: CALayer) {
    super.layoutSublayers(of: layer)
    if layer == self.layer {
      indicator.frame = layer.bounds
      indicator.path = antenna.cgPath
    }
  }
}

extension TransformerView { // ViewInitializing
  override func configure() {
    body.backgroundColor = .systemTintColor
    body.layer.masksToBounds = true
    body.layer.cornerRadius = 10

    indicator.lineWidth = 2
    indicator.strokeColor = UIColor.systemTintColor.cgColor
    indicator.fillColor = UIColor.systemTintColor.cgColor
  }

  override func buildUserInterface() {
    addSubview(body)
    addSubview(icon)
    layer.addSublayer(indicator)
  }

  override func activateDefaultLayout() {
    icon.centerYAnchor == self.centerYAnchor
    icon.trailingAnchor == self.trailingAnchor + 2

    body.edgeAnchors == icon.edgeAnchors - 10

    widthAnchor == 60
    heightAnchor == 80
  }
}

final class TransformerIcon: UIView {

  fileprivate let leftLayer = CAShapeLayer()
  fileprivate let rightLayer = CAShapeLayer()

  fileprivate var leftPath: UIBezierPath {
    let p = UIBezierPath()
    p.addArc(withCenter: CGPoint(x: 2, y: 2), radius: 2, startAngle: 0, endAngle: CGFloat(2 * Double.pi), clockwise: true)
    p.addLine(to: CGPoint(x: 12, y: 2))
    p.addLine(to: CGPoint(x: 12, y: 12))
    p.addArc(withCenter: CGPoint(x: 13, y: 14), radius: 2, startAngle: CGFloat(3 * Double.pi / 2), endAngle: CGFloat(Double.pi / 2), clockwise: true)
    p.addLine(to: CGPoint(x: 12, y: 16))
    p.addArc(withCenter: CGPoint(x: 13, y: 18), radius: 2, startAngle: CGFloat(3 * Double.pi / 2), endAngle: CGFloat(Double.pi / 2), clockwise: true)
    p.addLine(to: CGPoint(x: 12, y: 20))
    p.addArc(withCenter: CGPoint(x: 13, y: 22), radius: 2, startAngle: CGFloat(3 * Double.pi / 2), endAngle: CGFloat(Double.pi / 2), clockwise: true)
    p.addLine(to: CGPoint(x: 12, y: 24))
    p.addArc(withCenter: CGPoint(x: 13, y: 26), radius: 2, startAngle: CGFloat(3 * Double.pi / 2), endAngle: CGFloat(Double.pi / 2), clockwise: true)
    p.addLine(to: CGPoint(x: 12, y: 28))
    p.addLine(to: CGPoint(x: 12, y: 38))
    p.addArc(withCenter: CGPoint(x: 2, y: 38), radius: 2, startAngle: 0, endAngle: CGFloat(2 * Double.pi), clockwise: true)
    p.move(to: CGPoint(x: 19, y: 12))
    p.addLine(to: CGPoint(x: 19, y: 28))
    return p
  }

  fileprivate var rightPath: UIBezierPath {
    let p = UIBezierPath()
    p.move(to: CGPoint(x: 40, y: 2))
    p.addLine(to: CGPoint(x: 26, y: 2))
    p.addLine(to: CGPoint(x: 26, y: 12))
    p.addArc(withCenter: CGPoint(x: 25, y: 14), radius: 2, startAngle: CGFloat(3 * Double.pi / 2), endAngle: CGFloat(Double.pi / 2), clockwise: false)
    p.addLine(to: CGPoint(x: 26, y: 16))
    p.addArc(withCenter: CGPoint(x: 25, y: 18), radius: 2, startAngle: CGFloat(3 * Double.pi / 2), endAngle: CGFloat(Double.pi / 2), clockwise: false)
    p.addLine(to: CGPoint(x: 26, y: 20))
    p.addArc(withCenter: CGPoint(x: 25, y: 22), radius: 2, startAngle: CGFloat(3 * Double.pi / 2), endAngle: CGFloat(Double.pi / 2), clockwise: false)
    p.addLine(to: CGPoint(x: 26, y: 24))
    p.addArc(withCenter: CGPoint(x: 25, y: 26), radius: 2, startAngle: CGFloat(3 * Double.pi / 2), endAngle: CGFloat(Double.pi / 2), clockwise: false)
    p.addLine(to: CGPoint(x: 26, y: 28))
    p.addLine(to: CGPoint(x: 26, y: 38))
    p.addLine(to: CGPoint(x: 40, y: 38))
    return p
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    initialize()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSublayers(of layer: CALayer) {
    super.layoutSublayers(of: layer)
    if layer == self.layer {
      leftLayer.path = leftPath.cgPath
      rightLayer.path = rightPath.cgPath
    }
  }

  override var intrinsicContentSize: CGSize {
    return CGSize(width: 40, height: 40)
  }
}

extension TransformerIcon { // ViewInitializing

  override func configure() {
    backgroundColor = .clear
    configure(leftLayer, with: .white)
    configure(rightLayer, with: .white)
  }

  override func buildUserInterface() {
    layer.addSublayer(leftLayer)
    layer.addSublayer(rightLayer)
  }
}

fileprivate extension TransformerIcon {

  func configure(_ layer: CAShapeLayer, with color: UIColor) {
    layer.fillColor = UIColor.clear.cgColor
    layer.strokeColor = color.cgColor
    layer.lineWidth = 2
    layer.lineCap = CAShapeLayerLineCap.round
    layer.lineJoin = CAShapeLayerLineJoin.round
  }
}
