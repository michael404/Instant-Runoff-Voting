public struct VoteCounter<Option: Votable> {
    
    fileprivate var voteCountingRounds: [VoteCountingRound<Option>]
    
    /// The winning option of the vote
    let winner: Option
    
    /// An array of dictionaries indicating the number of votes for the options
    /// in all the rounds
    var results: [[Option: Int]] {
        return self.voteCountingRounds.map({ $0.numberOfVotesPerOption })
    }
    
    /// Initialize and do the counting
    init(ballot: [Vote<Option>]) throws {
                
        // Set up first round
        voteCountingRounds = [VoteCountingRound(fromUncountedBallot: ballot)]
        
        // As long as no option has majority, keep adding more elimination rounds by
        // seting up the next round based on the current and continue looping.
        // Otherwise, break the loop.
        while let voteCountingRound = voteCountingRounds.last, voteCountingRound.optionWithMajority() == nil {
            voteCountingRounds.append(try VoteCountingRound(fromPreviousRound: voteCountingRound))
        }
        
        self.winner = voteCountingRounds.last!.optionWithMajority()!
    }
}

extension VoteCounter: CustomStringConvertible {
    
    public var description: String {
        
        var desc = String()
        
        desc += ("Number of votes in uncounted ballot: \(voteCountingRounds[0].totalVotes)\n")
        
        for round in voteCountingRounds.indices {
            desc += "\nRound \(round)\n"
            
            if round > 0 {
                desc += "\(voteCountingRounds[round].eliminatedOptions.count) option(s) were eliminated in the round\n"
                for eliminatedOption in voteCountingRounds[round].eliminatedOptions {
                    desc += "Option to eliminate: \(eliminatedOption)\n"
                    for voteToRedistribute in voteCountingRounds[round - 1].votes(for: eliminatedOption) {
                        desc += " - Resorting vote: \(voteToRedistribute)\n"
                    }
                }
            }
            
            desc += "Number of valid votes in this round: \(voteCountingRounds[round].totalVotes)\n"
            
            desc += "Current count: "
            for (option, vote) in voteCountingRounds[round].voteCount {
                desc += "\(option): \(vote.count), "
            }
            
            desc += "\nCurrent distribution:\n"
            for (option, vote) in voteCountingRounds[round].voteCount {
                desc += " - \(option): \(vote)\n"
            }
            
            if let winner = voteCountingRounds[round].optionWithMajority() {
                desc += "Found winner: \(winner)\n\n"
            } else {
                desc += "No winner found in this round, moving on to next\n\n"
            }
        }
        
        return desc
    }
}
