public enum VoteError: Error {
    case noOptionsInVote
    case duplicateOptionsInVote
    case votesAlreadyCounted
    case unresolvableTie
}

extension Collection where Element: Hashable {
    
    /// Checks if all elements in the collection are unique
    ///
    /// - Returns: `true` if all elements are unique, otherwise `false`
    var elementsAreUnique: Bool {
        var set = Set<Element>(minimumCapacity: self.count)
        for element in self {
            guard set.insert(element).inserted else { return false }
        }
        return true
    }
    
}

extension Sequence {
    
    /// Calculate the sum of the elements in the sequence,
    /// calculating the value of each element by the closure
    ///
    /// - Parameter counting: the closure to use to calculate the value of each element
    /// - Returns: the sum of the sequence
    func sum<N: Numeric>(countingElementsBy counting: (Element) -> N) -> N {
        return self.reduce(0 as N) { result, item in
            return result + counting(item)
        }
    }
    
}

extension Sequence where Element: Numeric {
    
    /// The sum of the elements in the sequence
    var sum: Element {
        return self.reduce(0, +)
    }
    
}


