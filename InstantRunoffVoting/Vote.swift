public typealias Votable = Equatable & Hashable & CustomStringConvertible

public struct Vote<Option: Votable>: Sequence, CustomStringConvertible {
    
    fileprivate let rankedVotes: [Option]
    
    init(preferences: [Option]) throws {
        guard !preferences.isEmpty else { throw VoteError.noPreferencesInVote }
        guard preferences.elementsAreUnique() else { throw VoteError.duplicatePreferencesInVote }
        self.rankedVotes = preferences
    }
    
    public func makeIterator() -> VoteIterator<Option> {
        return VoteIterator(self)
    }
    
    public var description: String {
        return self.rankedVotes.lazy.map({ $0.description }).joined(separator: ">")
    }
    
}

public struct VoteIterator<Option: Votable>: IteratorProtocol, CustomStringConvertible {
    
    private let vote: Vote<Option>
    
    private var index: Int = 0
    
    fileprivate init(_ vote: Vote<Option>) { self.vote = vote }
    
    /// Advance to the next preference and return it, or nil if no next preference exists
    mutating public func next() -> Option? {
        guard self.index < self.vote.rankedVotes.endIndex else { return nil }
        defer { self.index += 1 }
        return self.vote.rankedVotes[self.index]
    }
    
    public var description: String {
        return self.vote.description
    }
    
}

