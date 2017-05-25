import Foundation

protocol ClassStringProviding: class {
  static var classString: String { get }
}

extension ClassStringProviding {
  static var classString: String {
    return NSStringFromClass(self).components(separatedBy: ".").last!
  }
}

extension NSObject: ClassStringProviding {}
