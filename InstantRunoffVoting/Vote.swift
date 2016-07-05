public struct Vote<Option: Votable> {
    
    private let preferences: [Option]
    
    private var index: Array<Option>.Index
    
    init(preferences: [Option]) throws {        
        
        // Check that there is at least one preference
        guard !preferences.isEmpty else {
            throw VoteError.noPreferencesInVote
        }
        
        // Check that no option is preferred more than once
        guard Set(preferences).count == preferences.count else {
            throw VoteError.optionPreferredMoreThanOnceInVote
        }
        
        self.preferences = preferences
        self.index = self.preferences.startIndex
    }
    
    /// Advance to the next preference and return it, or nil if no next preference exists
    internal mutating func next() -> Option? {
        defer { index = preferences.index(after: index) }
        return index < preferences.endIndex ? preferences[index] : nil
    }
    
}

extension Vote: CustomStringConvertible {
    
    public var description: String {
        return self.preferences.map({ $0.description }).joined(separator: ">")
    }
    
}
