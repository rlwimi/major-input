import UIKit

/// Supports `UIViewController` subclasses overriding `loadView`. Conformance supports concise
/// declaration that a `UIViewController` subclass's `view` is a given `UIView` subclass. Provides
/// easy access to `view` as this type removing redundant casts.
///
/// Conformance is simple:
/// ```swift
/// extension MyViewController: ViewDowncasting {
///   typealias DowncastView: MyView
/// }
/// ```
protocol ViewDowncasting {

  associatedtype DowncastView

  /// Replace use of `view` property with this property. Avoids downcasting.
  /// - returns: `view` downcast as the view controller's associated subclass
  var downcastView: DowncastView { get }
}

extension ViewDowncasting where Self: UIViewController, Self.DowncastView: UIView {
  var downcastView: Self.DowncastView {
    return view as! Self.DowncastView
  }
}
