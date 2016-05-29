public struct VoteCounter<Option: Votable> {
    
    private var voteCountingRounds: [VoteCountingRound<Option>]
    
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
        
        // As long as no option has majority, keep adding more elimination rounds
        while let voteCountingRound = voteCountingRounds.last where voteCountingRound.optionWithMajority() == nil {
            
            // If no winner is found, set up next round based on the current
            voteCountingRounds.append(try VoteCountingRound(fromPreviousRound: voteCountingRound))
        }
        
        self.winner = voteCountingRounds.last!.optionWithMajority()!
        
    }
    
}

extension VoteCounter: CustomStringConvertible {
    
    public var description: String {
        
        var desc: String = ""
        
        desc += ("Number of votes in uncounted ballot: " + voteCountingRounds[0].totalVotes.description + "\n")
        
        for (round, voteCountingRound) in voteCountingRounds.enumerated() {
            desc += "\nRound " + round.description + "\n"
            
            if round > 0 {

                desc += voteCountingRound.eliminatedOptions.count.description + " option(s) were eliminated in the round\n"
                
                for eliminatedOption in voteCountingRound.eliminatedOptions {
                    desc += "Option to eliminate: " + eliminatedOption.description + "\n"
                    for voteToRedistribute in voteCountingRounds[round - 1].votesFor(option: eliminatedOption) {
                        desc += " - Resorting vote: " + voteToRedistribute.description + "\n"
                    }
                }
            }
            
            desc += "Number of valid votes in this round: " + voteCountingRound.totalVotes.description + "\n"
            
            desc += "Current count: "
            for (option, vote) in voteCountingRound.voteCount {
                desc += option.description + ": " + vote.count.description + ", "
            }
            
            desc += "\nCurrent distribution:\n"
            for (option, vote) in voteCountingRound.voteCount {
                desc += " - " + option.description + ": " + vote.description + "\n"
            }
            
            if let winner = voteCountingRound.optionWithMajority() {
                desc += "Found winner: " + winner.description + "\n\n"
            } else {
                desc += "No winner found in this round, moving on to next\n\n"
            }
        }
        
        return desc
    }
}