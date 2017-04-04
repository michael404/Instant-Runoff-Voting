struct VoteCountingRound<Option: Votable> {
    
    typealias Votes = [VoteIterator<Option>]
    
    private(set) var voteCount: [Option: Votes]
    
    private(set) var eliminatedOptions: [Option] = []
    
    var totalVotes: Int {
        return voteCount.reduce(0) { result, voteCount in
            result + voteCount.value.count
        }
    }
    
    var allOptions: LazyMapCollection<Dictionary<Option, Votes>, Option> {
        return voteCount.keys
    }
    
    var numberOfVotesPerOption: [Option: Int] {
        return Dictionary(voteCount.map { option, votes in
            return (option, votes.count)
        } )!
    }
    
    /// Initialize from an uncounted ballot.
    /// All options will be added to the vote count, since no votes are eliminated
    init(fromUncountedBallot ballot: [Vote<Option>]) {
        
        self.voteCount = [:]
        for var vote in ballot.map({ $0.makeIterator() }) {
            
            // Discard votes that do not have any preferences
            if let preference = vote.next() {
                
                // Add vote to array or initialize array if is not allready initialized
                self.voteCount[preference, or: []].append(vote)
            }
        }
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
        var optionsSortedByVotes = numberOfVotesPerOption.sorted(by: { lhs, rhs in
            return lhs.value < rhs.value
        } )
        
        
        // Continue looping until we find he most popular (last) option that individually has a
        // higher number of votes than all options after it.
        while optionsSortedByVotes.removeLast().1 <= optionsSortedByVotes.reduce(0, { result, voteCount in
            return result + voteCount.value
        } ) {
            continue
        }

        // We have found that option, and can therefore return every option
        // that is less popular than this
        return optionsSortedByVotes.flatMap({ $0.key })
    }
    
    /// Removes votes for the options specified from voteCount and returns an
    /// array of all votes that were removed
    private mutating func removeVotes(for options: [Option]) -> Votes {
        return options.flatMap({ option in
            self.voteCount.removeValue(forKey: option)!
        } )
    }
    
    /// Redistributes votes to the next preference that is stil valid, if
    /// that is available. Discards votes that do no longer have valid preferences.
    private mutating func redistribute(votes: Votes) {
        for var vote in votes {
            while let preference = vote.next() {
                // Only add votes to options that are still valid in this round
                guard voteCount[preference]?.append(vote) == nil else { break }
            }
        }
    }
    
    /// Checks if there is an option that has more than 50% of the votes and returns that
    /// option or nil if it does not exist
    func optionWithMajority() -> Option? {
        let votesNeededForMajority = self.totalVotes / 2
        return voteCount.first(where: { voteCount in
            voteCount.value.count > votesNeededForMajority
        } )?.key
    }
    
    func votes(for option: Option) -> Votes {
        return voteCount[option] ?? []
    }
    
}
