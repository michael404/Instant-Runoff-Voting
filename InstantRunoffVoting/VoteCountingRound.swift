struct VoteCountingRound<Option: Votable> {
    
    typealias Votes = [Vote<Option>]
    
    private(set) var voteCount: [Option: Votes]
    
    private(set) var eliminatedOptions: [Option] = []
    
    var totalVotes: Int {
        return voteCount.sum { $0.value.count }
    }
    
    var allOptions: Dictionary<Option, Votes>.Keys {
        return voteCount.keys
    }
    
    var numberOfVotesPerOption: [Option: Int] {
        return voteCount.mapValues { $0.count }
    }
    
    /// Initialize from an uncounted ballot.
    /// All options will be added to the vote count, since no votes are eliminated
    init(fromUncountedBallot ballot: [Vote<Option>]) {
        self.voteCount = Dictionary(grouping: ballot) { $0.first }
    }
    
    /// Initialize from a previous round. This will include trying to eliminate options.
    init(fromPreviousRound previousRound: VoteCountingRound<Option>) throws {
        
        // Copy over the voteCount from the last round as a start
        self.voteCount = previousRound.voteCount
        
        self.eliminatedOptions = optionsToEliminate()
        
        // Check that we eliminate at least one option
        guard !self.eliminatedOptions.isEmpty else {
            throw VoteError.unresolvableTie
        }
        
        let votesToRedistribute = removeVotes(for: self.eliminatedOptions)
        
        redistribute(votes: votesToRedistribute)
    }
    
    /// Find options to eliminate.
    /// The elemination algorithm is aggressive, and eliminates all options that together
    /// have less votes than the last option not to be eliminated.
    private func optionsToEliminate() -> [Option] {
        
        // Sort options by popularity (from least popular to most popular), so that they can
        // be eliminated one by one.
        var optionsSortedByVotes = numberOfVotesPerOption.sorted { lhs, rhs in
            return lhs.value < rhs.value
        }
        
        
        // Continue looping until we find he most popular (last) option that individually has a
        // higher number of votes than all options after it.
        while optionsSortedByVotes.removeLast().value <= optionsSortedByVotes.sum { $0.value } {
            continue
        }

        // We have found that option, and can therefore return every option
        // that is less popular than this
        return optionsSortedByVotes.map({ $0.key })
    }
    
    /// Removes votes for the options specified from voteCount and returns an
    /// array of all votes that were removed
    private mutating func removeVotes(for options: [Option]) -> Votes {
        return options.flatMap { option in
            self.voteCount.removeValue(forKey: option)!
        }
    }
    
    /// Redistributes votes to the next preference that is stil valid, if
    /// that is available. Discards votes that do no longer have valid preferences.
    private mutating func redistribute(votes: Votes) {
        for vote in votes {
            for nextRankedOption in vote {
                // Only add votes to options that are still valid in this round
                guard voteCount[nextRankedOption]?.append(vote) == nil else { break }
            }
        }
    }
    
    /// Checks if there is an option that has more than 50% of the votes and returns that
    /// option or nil if it does not exist
    func optionWithMajority() -> Option? {
        let votesNeededForMajority = self.totalVotes / 2
        return voteCount.first { voteCount in
            voteCount.value.count > votesNeededForMajority
        }?.key
    }
    
    func votes(for option: Option) -> Votes {
        return voteCount[option] ?? []
    }
    
}
