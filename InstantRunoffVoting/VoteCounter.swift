public final class VoteCounter<Option: Voteable> {
    
    private var voteCountingRounds: [VoteCountingRound<Option>]
    
    /// The winning option of the vote
    // TODO: In Swift 2.2, remove the force-unwrapping
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
    
    /// Prints the results in a nicely formatted way
    func printResults() {
        
        print("Number of votes in uncounted ballot: " + voteCountingRounds[0].totalVotes.description)
        
        for (round, voteCountingRound) in voteCountingRounds.enumerate() {
            print("\nRound " + round.description)
            
            if round > 0 {
                
                // Check which options have been eliminated since the last round
                let lastRoundOptions = Set(voteCountingRounds[round - 1].allOptions)
                let thisRoundOption = Set(voteCountingRound.allOptions)
                let optionsToEliminate = lastRoundOptions.subtract(thisRoundOption)
                
                print(optionsToEliminate.count.description + " option(s) were eliminated in the same round")
                
                for optionToEliminate in optionsToEliminate {
                    print("Option to eliminate: " + optionToEliminate.description)
                    for voteToRedistribute in voteCountingRounds[round - 1].votesFor(optionToEliminate) {
                        print(" - Resorting vote: " + voteToRedistribute.description)
                    }
                }
            }
            
            print("Number of valid votes in this round: " + voteCountingRound.totalVotes.description)
            
            print("Current count: ", terminator: "")
            for (option, vote) in voteCountingRound {
                print(option.description + ": " + vote.count.description + ", ", terminator: "")
            }
            print("")
            
            print("Current distribution:")
            for (option, vote) in voteCountingRound {
                print(" - " + option.description + ": " + vote.description
                )
            }
            
            if let winner = voteCountingRound.optionWithMajority() {
                print("Found winner:" + winner.description + "\n")
                return
            }
            print("No winner found in this round, moving on to next")
        }
    }
    
}