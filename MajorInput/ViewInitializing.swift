import UIKit

/// Provides structure to the often ad hoc nature of `UIView` setup. Because Auto Layout requires
/// `NSLayoutConstraint` items to share a common ancestor, it is critical that the view hierarchy is
/// built before the layout is activated. Completing the construction of the view hierarchy before
/// activating any layout constraints minimizes the fragility resulting from order-of-operations
/// dependencies that arise when constraint activation is mixed with hierarchy construction. Strict
/// separation is critical to supporting view subclassing. Other benefits include a standardization
/// of common operations which go by any number of different names.
///
/// These methods are intended to be called at init-time, in order:
///
/// 1. configure
/// 2. buildUserInterface
/// 3. activateDefaultLayout
///
/// This order of operations is encapsulated by a default implementation of `initialize`, an
/// instance not to be confused with the Objective-C/`NSObject` class method (which will no longer
/// be callable from Swift 4).
///
/// Typically, these methods *should not* call super.
///
/// Each class in a hierarchy should call `initialize` and take care of its own responsibilities.
/// However, if a particular design, perhaps a template pattern where a subclass provides its
/// "abstract" superclass with a particular subview, requires these methods to call super in or to
/// build the complete view hierarchy spanning a class hierarchy before applying any layout, calling
/// super first in these methods meets that need. If you encounter such a design consider whether
/// you find dependency-injection via subclass to be a code smell, whether you reallyy want to deal
/// with the complexity from interactions of merging two hierarchies (subview and subclass).
protocol ViewInitializing {

  /// Configure self and subviews.
  func configure()

  /// Construct subview and sublayer hierarchies here.
  func buildUserInterface()

  /// Layout should always be constrained down the hierarchy and not up. Views are not limited to
  /// a single layout, but layout of the instance's subview hierarchy should be fully constrained
  /// by the end of this method.
  func activateDefaultLayout()
}

extension ViewInitializing {
  func configure() {}
  func buildUserInterface() {}
  func activateDefaultLayout() {}

  /// Calls initialization operations in the appropriate order.
  func initialize() {
    configure()
    buildUserInterface()
    activateDefaultLayout()
  }
}

/// `UIView` and `UIViewController` are given seemingly repetitive empty implementations below. This
/// supports subclasses implementing these methods as overrides without knowing whether the super-
/// class implements the method.

extension UIView: ViewInitializing {
  @objc func configure() {}
  func buildUserInterface() {}
  func activateDefaultLayout() {}
}

extension UIViewController: ViewInitializing {
  func configure() {}
  func buildUserInterface() {}
  func activateDefaultLayout() {}
}
