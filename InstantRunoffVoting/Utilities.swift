public enum VoteError: Error {
    case noPreferencesInVote
    case duplicatePreferencesInVote
    case votesAlreadyCounted
    case unresolvableTie
}

extension Array where Iterator.Element: Hashable {
    
    func elementsAreUnique() -> Bool {
        return Set(self).count == self.count
    }
    
}

extension Dictionary {
    
    // TODO: If this proposal gets included in Swift:
    // https://github.com/apple/swift-evolution/blob/master/proposals/0165-dict.md
    // this helper subscript can be removed.
    //
    /// Accesses the element with the given key, or the specified default value,
    /// if the dictionary doesn't contain the given key.
    ///
    /// - Parameters:
    ///   - key: The key to look up.
    ///   - defaultValue: The value to use if the dictionary does not contain the key.
    subscript(key: Key, default defaultValue: @autoclosure () -> Value) -> Value {
        get {
            return self[key] ?? defaultValue()
        }
        set {
            self[key] = newValue
        }
    }
    
    // TODO: If this proposal gets included in Swift:
    // https://github.com/apple/swift-evolution/blob/master/proposals/0165-dict.md
    // this helper init can be removed.
    //
    /// Creates a new dictionary using the key/value pairs in the given
    /// sequence.
    ///
    /// If the given sequence has any duplicate keys, the initialization
    /// traps with a fatalError().
    ///
    /// - Parameter sequence:  A sequence of `(Key, Value)` tuples, where
    ///   the type `Key` conforms to the `Hashable` protocol.
    /// - Returns: A new dictionary initialized with the elements of
    ///   `sequence` if all keys are unique.
    init<S: Sequence>(_ sequence: S) where S.Iterator.Element == (Key, Value) {
        self = Dictionary(minimumCapacity: sequence.underestimatedCount)
        for (key, value) in sequence {
            guard self.updateValue(value, forKey: key) == nil else { fatalError() }
        }
    }
    
}

extension Sequence {
    
    /// Calculate the sum of the elements in the sequence,
    /// calculating the `Int` value of each element by the closure
    ///
    /// - Parameter counting: the closure to use to calculate the value of each element
    /// - Returns: the sum of the sequence
    func sum(countingElementsBy counting: (Iterator.Element) -> Int) -> Int {
        return self.reduce(0) { result, item in
            return result + counting(item)
        }
    }
    
}

//TODO: This should be generic over one of the new Swift 4 integer protocols
extension Sequence where Iterator.Element == Int {
    
    /// The sum of the `Int` elements in the sequence
    var sum: Int {
        return self.reduce(0, +)
    }
    
}


