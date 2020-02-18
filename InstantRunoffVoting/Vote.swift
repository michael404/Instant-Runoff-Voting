public typealias Votable = Hashable & CustomStringConvertible

public struct Vote<Option: Votable> {
    
    private let rankedOptions: [Option]
    
    init(rankedOptions: [Option]) throws {
        guard !rankedOptions.isEmpty else { throw VoteError.noOptionsInVote }
        guard rankedOptions.elementsAreUnique else { throw VoteError.duplicateOptionsInVote }
        self.rankedOptions = rankedOptions
    }
    
    public var first: Option {
        return self.rankedOptions[self.rankedOptions.startIndex]
    }
    
}

extension Vote: Sequence {
    
    public func makeIterator() -> Array<Option>.Iterator {
        return self.rankedOptions.makeIterator()
    }
    
}

extension Vote: CustomStringConvertible {
    
    public var description: String {
        return self.rankedOptions.map({ $0.description }).joined(separator: ">")
    }
    
}
