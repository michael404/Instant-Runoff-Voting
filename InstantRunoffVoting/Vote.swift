public final class Vote<Option: Votable> {
    
    private let preferences: [Option]
    
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
    }
    
    /// Returns a VoteGenerator that keeps a copy of the vote
    /// and maintains iteration state
    public func generate() -> VotePreferenceIterator<Option> {
        return VotePreferenceIterator<Option>(vote: self)
    }

}

extension Vote: CustomStringConvertible {
    
    public var description: String {
        return self.preferences.map({ $0.description }).joinWithSeparator(">")
    }
    
}

public final class VotePreferenceIterator<Option: Votable> {

    private var iterator: IndexingGenerator<[Option]>
    private let _description: String
    
    init(vote: Vote<Option>) {
        self.iterator = vote.preferences.generate()
        self._description = vote.description
    }
    
    public func next() -> Option? {
        return self.iterator.next()
    }
    
}

extension VotePreferenceIterator: CustomStringConvertible {
    
    public var description: String {
        return self._description
    }
    
}