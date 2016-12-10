public typealias Votable = Equatable & Hashable & CustomStringConvertible

public struct Vote<Option: Votable>: Sequence, CustomStringConvertible {
    
    fileprivate let preferences: [Option]
    
    public typealias Iterator = VoteIterator<Option>
    
    init(preferences: [Option]) throws {        
        
        guard !preferences.isEmpty else { throw VoteError.noPreferencesInVote }
        
        guard preferences.hasUniqueElements() else { throw VoteError.optionPreferredMoreThanOnceInVote }
        
        self.preferences = preferences
    }
    
    public func makeIterator() -> VoteIterator<Option> {
        return VoteIterator(self)
    }
    
    public var description: String {
        return self.preferences.lazy.map({ $0.description }).joined(separator: ">")
    }
    
}

public struct VoteIterator<Option: Votable>: IteratorProtocol, CustomStringConvertible {
    
    fileprivate let vote: Vote<Option>
    
    private var index: Array.Index = 0
    
    fileprivate init(_ vote: Vote<Option>) {
        self.vote = vote
    }
    
    /// Advance to the next preference and return it, or nil if no next preference exists
    mutating public func next() -> Option? {
        defer { self.index += 1 }
        return self.index < self.vote.preferences.endIndex ? self.vote.preferences[index] : nil
    }
    
    public var description: String {
        return self.vote.description
    }
    
}

