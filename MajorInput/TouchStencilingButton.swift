import UIKit

final class TouchStencilingButton: UIButton {

  /// List of views to which the instance will pass through touches.
  var stenciledViews: [UIView] = []

  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .clear
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
    guard super.point(inside: point, with: event)
      else { return false }
    let stenciled = stenciledViews.first { stenciledView in
      guard stenciledView.isHiddenInHierarchy == false else { return false }
      let convertedPoint = self.convert(point, to: stenciledView)
      let inside = stenciledView.point(inside: convertedPoint, with: event)
      return inside
    }
    let consumeTouch = (stenciled == nil)
    return consumeTouch
  }
}
