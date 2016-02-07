public final class VoteCounter<Option: Voteable> {
    
    private var voteCountingRounds: [VoteCountingRound<Option>]
    
    /// The winning option of the vote
    // TODO: In Swift 2.2, remove the force-unwrapping, and change to "public let"
    private(set) var winner: Option!
    
    /// An array of dictionaries indicating the number of votes for the options
    /// in all the rounds
    var results: [[Option: Int]] {
        return self.voteCountingRounds.map({ $0.results })
    }
    
    /// Initialize and do the counting
    init(ballot: [Vote<Option>]) throws {
                
        // Set up first round
        voteCountingRounds = [VoteCountingRound(fromUncountedBallot: ballot)]
        
        // As long as no option has majority, keep adding more elimination rounds
        while let voteCountingRound = voteCountingRounds.last where voteCountingRound.optionWithMajority() == nil {
            
            // If no winner is found, set up next round based on the current
            voteCountingRounds.append(try VoteCountingRound(setUpNextRoundFromPreviousRound: voteCountingRound))
        }
        
        self.winner = voteCountingRounds.last!.optionWithMajority()!
        
    }
    
}

extension VoteCounter: CustomStringConvertible {
    
    public var description: String {
        
        var desc: String = ""
        
        
        desc += ("Number of votes in uncounted ballot: " + voteCountingRounds[0].totalVotes.description + "\n")
        
        for (round, voteCountingRound) in voteCountingRounds.enumerate() {
            desc += "\nRound " + round.description + "\n"
            
            if round > 0 {
                
                // Check which options have been eliminated since the last round
                let lastRoundOptions = Set(voteCountingRounds[round - 1].allOptions)
                let thisRoundOption = Set(voteCountingRound.allOptions)
                let optionsToEliminate = lastRoundOptions.subtract(thisRoundOption)
                
                desc += optionsToEliminate.count.description + " option(s) were eliminated in the same round\n"
                
                for optionToEliminate in optionsToEliminate {
                    desc += "Option to eliminate: " + optionToEliminate.description + "\n"
                    for voteToRedistribute in voteCountingRounds[round - 1].votesFor(optionToEliminate) {
                        desc += " - Resorting vote: " + voteToRedistribute.description + "\n"
                    }
                }
            }
            
            desc += "Number of valid votes in this round: " + voteCountingRound.totalVotes.description + "\n"
            
            desc += "Current count: "
            for (option, vote) in voteCountingRound {
                desc += option.description + ": " + vote.count.description + ", "
            }
            desc += "\n"
            
            desc += "Current distribution:\n"
            for (option, vote) in voteCountingRound {
                desc += " - " + option.description + ": " + vote.description + "\n"
            }
            
            if let winner = voteCountingRound.optionWithMajority() {
                desc += "Found winner:" + winner.description + "\n\n"
            } else {
                desc += "No winner found in this round, moving on to next\n\n"
            }
        }
        return desc
    }
    
}