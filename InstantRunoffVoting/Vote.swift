public final class Vote<VotingOption: Voteable> {
    
    private let preferences: [VotingOption]
    
    init(preferences: [VotingOption]) throws {
        self.preferences = preferences
        
        guard !self.preferences.isEmpty else {
            throw VoteError.NoPreferencesInVote
        }
        
        //Check that no option is preferred more than once
        guard Set(self.preferences).count == self.preferences.count else {
            throw VoteError.OptionPreferredMoreThanOnceInVote
        }
    }
    
}

extension Vote: SequenceType {
    
    public typealias Generator = VoteGenerator<VotingOption>
    
    public func generate() -> Vote.Generator {
        return VoteGenerator<VotingOption>(vote: self)
    }
}

public final class VoteGenerator<VotingOption: Voteable>: AnyGenerator<VotingOption> {

    private let vote: Vote<VotingOption>
    private var preferenceGenerator: IndexingGenerator<[VotingOption]>
    
    init(vote: Vote<VotingOption>) {
        self.vote = vote
        preferenceGenerator = self.vote.preferences.generate()
        super.init()
    }
    
    override public func next() -> VotingOption? {
        return self.preferenceGenerator.next()
    }
    
}

extension VoteGenerator: CustomStringConvertible {
    public var description: String {
        get {
            return self.vote.preferences.map{ $0.description }.joinWithSeparator(">")
        }
    }
}