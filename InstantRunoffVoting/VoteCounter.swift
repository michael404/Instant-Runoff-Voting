public final class VoteCounter<Option: Voteable> {
    
    private var voteCountingRounds: [VoteCountingRound<Option>]
    
    private var round = 0
    
    /// The winning option of the vote
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
        
        // Start looping though elimination rounds until one option has won
        while true {
            
            // Check if there is a winner and return the winner
            if let winner = voteCountingRounds[round].optionWithMajority() {
                self.winner = winner
                return
            }
            
            // If no winner is found, set up next round as a copy of the current,
            // find the options to eliminate, and redistribute votes
            try voteCountingRounds.append(VoteCountingRound(setUpNextRoundFromPreviousRound: voteCountingRounds[round]))
            round += 1
        }
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