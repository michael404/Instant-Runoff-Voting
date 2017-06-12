public enum VoteError: Error {
    case noPreferencesInVote
    case duplicatePreferencesInVote
    case votesAlreadyCounted
    case unresolvableTie
}

// TODO: Change this to work on all collections
extension Array where Element: Hashable {
    
    /// Checks if all elements in the sequence are unique
    ///
    /// - Returns: `true` if all elements are unique, otherwise `false`
    func elementsAreUnique() -> Bool {
        var set = Set<Element>(minimumCapacity: self.count)
        for element in self {
            guard set.insert(element).inserted else { return false }
        }
        return true
    }
    
}

// TODO: Change all Iterator.Element to Element when that change lands on the Swift 4 snapshot build

extension Sequence {
    
    /// Calculate the sum of the elements in the sequence,
    /// calculating the value of each element by the closure
    ///
    /// - Parameter counting: the closure to use to calculate the value of each element
    /// - Returns: the sum of the sequence
    func sum<N: Numeric>(countingElementsBy counting: (Iterator.Element) -> N) -> N {
        return self.reduce(0 as N) { result, item in
            return result + counting(item)
        }
    }
    
}

extension Sequence where Iterator.Element: Numeric {
    
    /// The sum of the elements in the sequence
    var sum: Iterator.Element {
        return self.reduce(0, +)
    }
    
}


