internal struct VoteCountingRound<Option: Votable> {
    
    internal typealias Votes = [Vote<Option>]
    
    private var voteCount: [Option: Votes]
    
    var totalVotes: Int {
        return voteCount.reduce(0, combine: { $0 + $1.1.count })
    }
    
    var allOptions: [Option] {
        return Array(voteCount.keys)
    }
    
    var results: [Option: Int] {
        
        // TODO: If this proposal gets included in Swift 3:
        // https://github.com/apple/swift-evolution/pull/125
        // ...this can be changed to:
        // return Dictionary(voteCount.map({ $0, $1.count }))!
        
        var results: [Option: Int] = [:]
        for (option, votes) in voteCount {
            results[option] = votes.count
        }
        return results
    }
    
    /// Initialize from an uncounted ballot.
    /// All options will be added to the vote count, since no votes are eliminated
    init(fromUncountedBallot ballot: [Vote<Option>]) {
        
        voteCount = [:]
        
        for var vote in ballot {
            
            // Discard votes that do not have any active preference
            if let activePreference = vote.next() {
                // Add vote to array or initialize array if is not allready initialized
                if let _ = voteCount[activePreference] {
                    voteCount[activePreference]!.append(vote)
                } else {
                    voteCount[activePreference] = [vote]
                }
            }
        }
    }
    
    /// Initialize from a previous round. This will include trying to eliminate options.
    /// The elemination algorithm is aggressive, and eliminates all options that together
    /// have less votes than the last option not to be eliminated.
    init(setUpNextRoundFromPreviousRound previousRound: VoteCountingRound<Option>) throws {
        
        self.voteCount = previousRound.voteCount
        
        // Sort options by popularity (from least popular to most popular), so that they can
        // be eliminated one by one.
        var votesRemaining = voteCount.sort({ $0.1.count < $1.1.count })
        
        // Continue looping until we find he most popular (last) option that individually has a
        // higher number of votes than all options after it.
        while votesRemaining.removeLast().1.count <= votesRemaining.reduce(0, combine: { $0 + $1.1.count }) {
            continue
        }

        // We have found that vote, and can therefore every option
        // that is less popular than this vote
        for optionToRemove in votesRemaining.map({ $0.0 }) {
            voteCount.removeValueForKey(optionToRemove)
        }
        
        let votesToRedistribute = votesRemaining.flatMap({ $0.1 })
        
        // Check that we eliminate at least one option
        guard !votesToRedistribute.isEmpty else {
            throw VoteError.UnresolvableTie
        }

        // Redistribute the votes to the next voting option that are stil valid
        for var vote in votesToRedistribute {
        
            while let preference = vote.next() {
                
                // Only add votes to options that are still valid in this round
                if let _ = voteCount[preference] {
                    voteCount[preference]!.append(vote)
                    break
                }
            }
        }
    }
    
    /// Checks if there is an option that has more than 50% of the votes and returns that
    /// option or nil if it does not exist
    @warn_unused_result
    internal func optionWithMajority() -> Option? {
        //TODO: Change to .find(where:) in Swift 3
        return voteCount.filter({ $0.1.count > (self.totalVotes / 2) }).map({ $0.0 }).first
    }
    
    @warn_unused_result
    internal func votesFor(option: Option) -> Votes {
        if let votes = voteCount[option] {
            return votes
        }
        return []
    }
    
}

extension VoteCountingRound: SequenceType {
    
    internal typealias Generator = DictionaryGenerator<Option, Votes>
    
    internal func generate() -> VoteCountingRound.Generator {
        return voteCount.generate()
    }
    
}