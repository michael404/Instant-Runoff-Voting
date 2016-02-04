
enum MichaelsVoteOptions: Voteable {
    case AltA
    case AltB
    case AltC
    case AltD
    
    var description: String {
        get {
            switch self {
            case .AltA: return "A"
            case .AltB: return "B"
            case .AltC: return "C"
            case .AltD: return "D"
            }
        }
    }
}

var votes: [Vote<MichaelsVoteOptions>] = []
votes.append(try! Vote(preferences: [.AltA, .AltB, .AltC]))
votes.append(try! Vote(preferences: [.AltA, .AltB, .AltC]))
votes.append(try! Vote(preferences: [.AltA, .AltB, .AltC, .AltD]))
votes.append(try! Vote(preferences: [.AltA, .AltB, .AltC]))
votes.append(try! Vote(preferences: [.AltA, .AltC, .AltB]))
votes.append(try! Vote(preferences: [.AltB, .AltA]))
votes.append(try! Vote(preferences: [.AltB, .AltA]))
votes.append(try! Vote(preferences: [.AltB, .AltA]))
votes.append(try! Vote(preferences: [.AltB, .AltD]))
votes.append(try! Vote(preferences: [.AltC]))
votes.append(try! Vote(preferences: [.AltD, .AltB]))
votes.append(try! Vote(preferences: [.AltD, .AltC, .AltB]))


let voteCounter = try VoteCounter(ballot: votes)

print(voteCounter.results)

print("----------------")

voteCounter.printResults()




