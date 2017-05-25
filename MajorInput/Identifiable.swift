struct Identifier<Resource>: RawRepresentable {
  let rawValue: String

  init(rawValue: String) {
    self.rawValue = rawValue
  }
}

protocol IdentifierProtocol: Hashable {}

extension Identifier: IdentifierProtocol {}

extension Identifier: Equatable {
  static func == (lhs: Identifier, rhs: Identifier) -> Bool {
    return lhs.rawValue == rhs.rawValue
  }
}

extension Identifier: Hashable {
  var hashValue: Int {
    return rawValue.hashValue
  }
}

protocol Identifiable: Hashable {
  associatedtype IdentifierType: IdentifierProtocol
  var identifier: IdentifierType { get }
}

extension Identifiable {
  var hashValue: Int {
    return identifier.hashValue
  }
}
