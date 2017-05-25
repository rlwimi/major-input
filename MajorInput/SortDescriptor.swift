import Foundation

typealias SortDescriptor<A> = (A, A) -> Bool

func sortDescriptor<Value, Property>(property: @escaping (Value) -> Property, ascending: Bool = true, comparator: @escaping (Property) -> (Property) -> ComparisonResult) -> SortDescriptor<Value> {
  return { value1, value2 in
    comparator(property(value1))(property(value2)) == (ascending ? .orderedAscending : .orderedDescending)
  }
}

func sortDescriptor<Value, Property>(property: @escaping ((Value) -> Property), ascending: Bool = true) -> SortDescriptor<Value> where Property: Comparable {
  return { value1, value2 in
    if ascending {
      return property(value1) < property(value2)
    } else {
      return property(value1) > property(value2)
    }
  }
}

func combine<A>(sortDescriptors: [SortDescriptor<A>]) -> SortDescriptor<A> {
  return { lhs, rhs in
    for descriptor in sortDescriptors {
      if descriptor(lhs,rhs) { return true }
      if descriptor(rhs,lhs) { return false }
    }
    return false
  }
}
