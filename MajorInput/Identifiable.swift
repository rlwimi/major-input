struct Identifier<Resource>: RawRepresentable, Hashable {
  let rawValue: String

  init(rawValue: String) {
    self.rawValue = rawValue
  }
}

protocol Identifiable: Hashable {
  associatedtype IdentifierType: Hashable
  var identifier: IdentifierType { get }
}
