public enum VoteError: Error {
    case noPreferencesInVote
    case duplicatePreferencesInVote
    case votesAlreadyCounted
    case unresolvableTie
}

extension Array where Iterator.Element: Hashable {
    
    func containsOnlyUniqueElements() -> Bool {
        return Set(self).count == self.count
    }
    
}

extension Dictionary {
    
    // TODO: If this proposal gets included in Swift:
    // https://github.com/apple/swift-evolution/blob/master/proposals/0100-add-sequence-based-init-and-merge-to-dictionary.md
    // this helper init can be removed.
    //
    /// Creates a new dictionary using the key/value pairs in the given
    /// sequence.
    ///
    /// If the given sequence has any duplicate keys, the result is `nil`.
    ///
    /// - Parameter sequence:  A sequence of `(Key, Value)` tuples, where
    ///   the type `Key` conforms to the `Hashable` protocol.
    /// - Returns: A new dictionary initialized with the elements of
    ///   `sequence` if all keys are unique; otherwise, `nil`.
    init?<S: Sequence>(_ sequence: S) where S.Iterator.Element == (Key, Value) {
        self = Dictionary(minimumCapacity: sequence.underestimatedCount)
        for (key, value) in sequence {
            guard self.updateValue(value, forKey: key) == nil else { return nil }
        }
    }
    
}
