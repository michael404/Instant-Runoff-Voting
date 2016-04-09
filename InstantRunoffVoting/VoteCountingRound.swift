internal final class VoteCountingRound<Option: Votable> {
    
    internal typealias Votes = [VotePreferenceIterator<Option>]
    
    private var voteCount: [Option: Votes]
    
    var totalVotes: Int {
        return voteCount.reduce(0, combine: { $0 + $1.1.count })
    }
    
    var allOptions: [Option] {
        return Array(voteCount.keys)
    }
    
    var results: [Option: Int] {
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
        for vote in ballot.map({ $0.generate() }) {
            if let preference = vote.next() {
                
                // Add vote to array or initialize array if is not allready initialized
                if var votesForPreference = voteCount[preference] {
                    votesForPreference.append(vote)
                    voteCount[preference] = votesForPreference
                } else {
                    voteCount[preference] = [vote]
                }
            }
        }
    }
    
    /// Initialize from a previous round.
    /// This will include trying to eliminate options
    init(setUpNextRoundFromPreviousRound round: VoteCountingRound<Option>) throws {
        
        self.voteCount = round.voteCount
        let votesToRedistribute = self.eliminateOptionsAndGetVotesToRedistribute()
        
        // Check that we do not try to eliminate no options
        guard !votesToRedistribute.isEmpty else {
            throw VoteError.UnresolvableTie
        }
        
        self.redistributeVotes(votesToRedistribute)
    }
    
    /// Checks if there is an option that has more than 50% of the votes and returns that
    /// option or nil if it does not exist
    @warn_unused_result
    internal func optionWithMajority() -> Option? {
        return voteCount.lazy.filter({ $0.1.count > (self.totalVotes / 2) }).map({ $0.0 }).first
    }
    
    @warn_unused_result
    internal func votesFor(option: Option) -> Votes {
        if let votes = voteCount[option] {
            return votes
        }
        return []
    }
    
    /// Removes the options that can be eliminated in this round and returns
    /// the corresponding votes that can be redistributed.
    /// The algorithm is aggressive, and eliminates all options that together have
    /// less votes than the last option not to be eliminated.
    @warn_unused_result
    private func eliminateOptionsAndGetVotesToRedistribute() -> Votes {
        
        // Sort options by popularity (from least popular to most popular), so that they can
        // be eliminated one by one. The most popular (last) option can/should not be eliminated
        var votesRemaining = voteCount.sort({ $0.1.count < $1.1.count }).dropLast()
        
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
        
        return votesRemaining.flatMap({ $0.1 })
    }
    
    /// Redistribute the votes to the next voting option that is stil valid
    private func redistributeVotes(votes: Votes) {
        for vote in votes {
            while let preference = vote.next() {
                // Only add votes to options that are still valid in this round
                if var votesForPreference = voteCount[preference] {
                    votesForPreference.append(vote)
                    voteCount[preference] = votesForPreference
                    break
                }
            }
        }
    }
}

extension VoteCountingRound: SequenceType {
    
    internal typealias Generator = DictionaryGenerator<Option, Votes>
    
    internal func generate() -> VoteCountingRound.Generator {
        return voteCount.generate()
    }
    
}