import QuartzCore
import UIKit

protocol LayerDowncasting {

  associatedtype DowncastLayer where DowncastLayer: CALayer

  static var layerClass: AnyClass { get }

  var downcastLayer: DowncastLayer { get }
}

extension LayerDowncasting where Self: UIView {

  var downcastLayer: DowncastLayer {
    return layer as! DowncastLayer
  }
}
