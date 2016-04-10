public struct Vote<Option: Votable> {
    
    private let preferences: [Option]
    
    private var index = 0
    
    public var activePreference: Option {
        return preferences[index]
    }
    
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
    
    public func selfWithNextPreference() -> Vote? {
        var voteCopy = self
        voteCopy.index += 1
        if index >= preferences.count {
            return nil
        } else {
            return voteCopy
        }
    }
    
}

extension Vote: CustomStringConvertible {
    
    public var description: String {
        return self.preferences.map({ $0.description }).joinWithSeparator(">")
    }
    
}
