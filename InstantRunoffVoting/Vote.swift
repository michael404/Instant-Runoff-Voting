public struct Vote<Option: Votable> {
    
    private let preferences: [Option]
    
    private var index: Int
    
    init(preferences: [Option]) throws {        
        
        // Check that there is at least one preference
        guard !preferences.isEmpty else {
            throw VoteError.NoPreferencesInVote
        }
        
        // Check that no option is preferred more than once
        guard Set(preferences).count == preferences.count else {
            throw VoteError.OptionPreferredMoreThanOnceInVote
        }
        
        self.preferences = preferences
        self.index = self.preferences.startIndex
    }
    
    internal func current() -> Option? {
        return preferences.indices.contains(index) ? preferences[index] : nil
    }
    
    internal mutating func next() -> Option? {
        defer { index = index.successor() }
        return current()
    }
    
}

extension Vote: CustomStringConvertible {
    
    public var description: String {
        return self.preferences.map({ $0.description }).joinWithSeparator(">")
    }
    
}
