public final class Vote<Option: Voteable> {
    
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
    
    // TODO: This used SequenceType before, but since Swift 2.2 this
    // does not seem to work
    
    /// Returns a VoteGenerator that keeps a copy of the vote
    /// and maintains iteration state
    public func generate() -> VoteGenerator<Option> {
        return VoteGenerator<Option>(vote: self)
    }

}

public final class VoteGenerator<Option: Voteable>: GeneratorType {

    private let vote: Vote<Option>
    private var preferenceGenerator: IndexingGenerator<[Option]>
    
    init(vote: Vote<Option>) {
        self.vote = vote
        preferenceGenerator = self.vote.preferences.generate()
    }
    
    public func next() -> Option? {
        return self.preferenceGenerator.next()
    }
    
}

extension VoteGenerator: CustomStringConvertible {
    
    public var description: String {
        return self.vote.preferences.map{ $0.description }.joinWithSeparator(">")
    }
    
}