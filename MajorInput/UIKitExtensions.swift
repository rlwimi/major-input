import UIKit

func afterSystemAnimation(do closure: @escaping () -> Void) {
  DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
    closure()
  }
}

protocol LayingOut {
  func setNeedsLayout()
  func layoutIfNeeded()
}

protocol LayoutForcing {
  func layoutImmediately()
}

extension LayoutForcing where Self: LayingOut {
  func layoutImmediately() {
    setNeedsLayout()
    layoutIfNeeded()
  }
}

extension UIView: LayingOut, LayoutForcing {}
extension CALayer: LayingOut, LayoutForcing {}

extension UICollectionView {
  func registerReusableCell<T: UICollectionViewCell>(_: T.Type) {
    register(T.self, forCellWithReuseIdentifier: T.classString)
  }

  func registerHeader<T: UICollectionReusableView>(_: T.Type) {
    register(T.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: T.classString)
  }

  func registerFooter<T: UICollectionReusableView>(_: T.Type) {
    register(T.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: T.classString)
  }

  func dequeueReusableCell<T: UICollectionViewCell>(indexPath: IndexPath) -> T {
    return dequeueReusableCell(withReuseIdentifier: T.classString, for: indexPath) as! T
  }

  func dequeueReusableSectionHeader<T: UICollectionReusableView>(indexPath: IndexPath) -> T {
    return dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: T.classString, for: indexPath) as! T
  }

  func dequeueReusableSectionFooter<T: UICollectionReusableView>(indexPath: IndexPath) -> T {
    return dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: T.classString, for: indexPath) as! T
  }
}

extension UICollectionView {
  /// Reload data and force layout.
  ///
  /// There is a window of time after calling `reloadData` in which layout has not yet occurred.
  /// During this window, methods like `layoutAttributesForItem(at:)` are executing against the
  /// data prior to the `reloadData` call. Forcing layout supports the use of layout attributes
  /// immediately after reloading data.
  func reloadDataImmediately() {
    reloadData()
    layoutImmediately()
  }
}

extension UIColor {
  @nonobjc private static let button: UIButton = {
    return UIButton(type: .system)
  }()

  @nonobjc static var systemTintColor: UIColor = {
    return UIColor.button.tintColor
  }()
}

extension UIEdgeInsets {

  var horizontalTotal: CGFloat {
    return left + right
  }

  var verticalTotal: CGFloat {
    return top + bottom
  }
}

extension UIEdgeInsets {
  public init(uniform: CGFloat) {
    self.init(top: uniform, left: uniform, bottom: uniform, right: uniform)
  }
}

extension UIEdgeInsets: ExpressibleByDictionaryLiteral {
  public typealias Key = EdgeKey
  public typealias Value = CGFloat

  public enum EdgeKey {
    case top
    case left
    case bottom
    case right
  }

  func keyPathForEdge(_ edgeKey: EdgeKey) -> WritableKeyPath<UIEdgeInsets, CGFloat> {
    switch edgeKey {
    case .top: return \UIEdgeInsets.top
    case .left: return \UIEdgeInsets.left
    case .bottom: return \UIEdgeInsets.bottom
    case .right: return \UIEdgeInsets.right
    }
  }

  public init(dictionaryLiteral elements: (EdgeKey, CGFloat)...) {
    self = UIEdgeInsets()

    for (inset, value) in elements {
      let keyPath = self.keyPathForEdge(inset)
      self[keyPath: keyPath] = value
    }
  }
}

extension UILayoutGuide {
  convenience init(identifier: String) {
    self.init()
    self.identifier = identifier
  }
}

extension UIView {
  func firstViewInHierarchy(where matcher: ((UIView) -> Bool)) -> UIView? {
    if matcher(self) {
      return self
    }
    for subview in subviews {
      if let first = subview.firstViewInHierarchy(where: matcher) {
        return first
      }
    }
    return nil
  }

  /// `true` if the instance or any of the views in its superview chain to its window are hidden.
  var isHiddenInHierarchy: Bool {
    guard isHidden == false else { return true }
    guard let superview = superview else { return false }
    return superview.isHiddenInHierarchy
  }
}
