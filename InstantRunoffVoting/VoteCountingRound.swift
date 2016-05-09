internal struct VoteCountingRound<Option: Votable> {
    
    internal typealias Votes = [Vote<Option>]
    
    private var voteCount: [Option: Votes]
    
    var totalVotes: Int {
        return voteCount.reduce(0, combine: { $0 + $1.1.count })
    }
    
    var allOptions: [Option] {
        return Array(voteCount.keys)
    }
    
    var numberOfVotesPerOption: [Option: Int] {
        
        // TODO: If this proposal gets included in Swift 3:
        // https://github.com/apple/swift-evolution/pull/125
        // ...this can be changed to:
        // return Dictionary(voteCount.map({ $0, $1.count }))!
        
        var numberOfVotesPerOption: [Option: Int] = [:]
        for (option, votes) in voteCount {
            numberOfVotesPerOption[option] = votes.count
        }
        return numberOfVotesPerOption
    }
    
    /// Initialize from an uncounted ballot.
    /// All options will be added to the vote count, since no votes are eliminated
    init(fromUncountedBallot ballot: [Vote<Option>]) {
        
        voteCount = [:]
        for var vote in ballot {
            
            // Discard votes that do not have any preferences
            if let preference = vote.next() {
                
                // Add vote to array or initialize array if is not allready initialized
                if voteCount[preference]?.append(vote) == nil {
                    voteCount[preference] = [vote]
                }
            }
        }
    }
    
    /// Initialize from a previous round. This will include trying to eliminate options.
    init(setUpNextRoundFromPreviousRound previousRound: VoteCountingRound<Option>) throws {
        
        // Copy over the voteCount from the last round as a start
        self.voteCount = previousRound.voteCount
        
        let optionsToEliminate = getOptionsToEliminate()
        
        // Check that we eliminate at least one option
        guard !optionsToEliminate.isEmpty else {
            throw VoteError.UnresolvableTie
        }
        
        let votesToRedistribute = removeVotesFor(options: optionsToEliminate)
        
        redistribute(votes: votesToRedistribute)
    }
    
    /// Find options to eliminate.
    /// The elemination algorithm is aggressive, and eliminates all options that together
    /// have less votes than the last option not to be eliminated.
    @warn_unused_result
    private func getOptionsToEliminate() -> [Option] {
        
        // Sort options by popularity (from least popular to most popular), so that they can
        // be eliminated one by one.
        var optionsSortedByVotes = numberOfVotesPerOption.sort({ $0.1 < $1.1 })
        
        
        // Continue looping until we find he most popular (last) option that individually has a
        // higher number of votes than all options after it.
        while optionsSortedByVotes.removeLast().1 <= optionsSortedByVotes.reduce(0, combine: { $0 + $1.1 }) {
            continue
        }

        // We have found that option, and can therefore return every option
        // that is less popular than this
        return optionsSortedByVotes.flatMap({ $0.0 })
    }
    
    /// Removes votes for the options specified from voteCount and returns an
    /// array of all votes that were removed
    @warn_unused_result
    private mutating func removeVotesFor(options options: [Option]) -> [Vote<Option>] {
        return options.flatMap({ self.voteCount.removeValueForKey($0)! })
    }
    
    /// Redistributes votes to the next preference that is stil valid, if
    /// that is available. Discards votes that do no longer have valid preferences.
    private mutating func redistribute(votes votes: Votes) {
        for var vote in votes {
            while let preference = vote.next() {
                // Only add votes to options that are still valid in this round
                if voteCount[preference]?.append(vote) != nil {
                    break
                }
            }
        }
    }
    
    /// Checks if there is an option that has more than 50% of the votes and returns that
    /// option or nil if it does not exist
    @warn_unused_result
    internal func optionWithMajority() -> Option? {
        
        let votesNeededForMajority = self.totalVotes / 2
        
        // TODO: When Swift 3 implements the this proposal:
        // https://github.com/apple/swift-evolution/blob/master/proposals/0032-sequencetype-find.md
        // this can be change to
        // return voteCount.first(where: { $0.1.count > votesNeededForMajority })?.0
        
        guard let indexOfOptionWithMajority = voteCount.indexOf({ $0.1.count > votesNeededForMajority }) else {
            return nil
        }
        return voteCount[indexOfOptionWithMajority].0
        
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