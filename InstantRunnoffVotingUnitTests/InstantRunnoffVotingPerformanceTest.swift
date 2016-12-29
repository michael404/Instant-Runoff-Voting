import XCTest

class InstantRunnoffVotingPerformanceTest: XCTestCase {
    
    enum TestOptions: String, Votable {
        case AltA = "A", AltB = "B", AltC = "C", AltD = "D", AltE = "E", AltF = "F"
        var description: String { return self.rawValue }
    }
    
    func testPerformanceOfFourRoundVote() {
        
        var votes: [Vote<TestOptions>] = []
        
        let performanceFactor = 300
        
        do {
            for _ in 1...(7 * performanceFactor) {
                votes.append(try Vote(preferences: [.AltA, .AltC, .AltF, .AltB]))
            }
            for _ in 1...(6 * performanceFactor) {
                votes.append(try Vote(preferences: [.AltB]))
            }
            for _ in 1...(5 * performanceFactor) {
                votes.append(try Vote(preferences: [.AltC]))
            }
            for _ in 1...(4 * performanceFactor) {
                votes.append(try Vote(preferences: [.AltD, .AltE, .AltF]))
            }
            for _ in 1...(2 * performanceFactor) {
                votes.append(try Vote(preferences: [.AltE, .AltA, .AltD]))
            }
            for _ in 1...(1 * performanceFactor) {
                votes.append(try Vote(preferences: [.AltF, .AltB, .AltC]))
            }
        } catch {
            XCTFail("Failed to create votes")
        }
        
        self.measure {
            withExtendedLifetime(try! VoteCounter(ballot: votes)) { }
        }
    }
    
    func testPerformanceWithManyOptions() {
        
        var votes: [Vote<Int>] = []
        
        do {
            for i in 1...150 {
                for _ in 1...i {
                    votes.append(try Vote(preferences: [i]))
                }
            }
        } catch {
            XCTFail("Failed to create votes")
        }
        
        self.measure {
            withExtendedLifetime(try! VoteCounter(ballot: votes).results) { }
        }
    }
    
    func testPerformanceOfVoteValidation() {
        
        var votes: [Vote<TestOptions>] = []
        
        let performanceFactor = 1200
        
        self.measure {
            do {
                for _ in 1...(7 * performanceFactor) {
                    votes.append(try Vote(preferences: [.AltA, .AltC, .AltF, .AltB]))
                }
                for _ in 1...(6 * performanceFactor) {
                    votes.append(try Vote(preferences: [.AltB]))
                }
                for _ in 1...(5 * performanceFactor) {
                    votes.append(try Vote(preferences: [.AltC]))
                }
                for _ in 1...(4 * performanceFactor) {
                    votes.append(try Vote(preferences: [.AltD, .AltE, .AltF]))
                }
                for _ in 1...(2 * performanceFactor) {
                    votes.append(try Vote(preferences: [.AltE, .AltA, .AltD]))
                }
                for _ in 1...(1 * performanceFactor) {
                    votes.append(try Vote(preferences: [.AltF, .AltB, .AltC]))
                }
            } catch {
                XCTFail("Failed to create votes")
            }
            withExtendedLifetime(votes) { }
        }
        
    }
    
    func testPerformanceOfVoteDescription() {
        
        var votes: [Vote<TestOptions>] = []
        
        let performanceFactor = 600
        
        do {
            for _ in 1...(7 * performanceFactor) {
                votes.append(try Vote(preferences: [.AltA, .AltC, .AltF, .AltB]))
            }
            for _ in 1...(6 * performanceFactor) {
                votes.append(try Vote(preferences: [.AltB]))
            }
            for _ in 1...(5 * performanceFactor) {
                votes.append(try Vote(preferences: [.AltC]))
            }
            for _ in 1...(4 * performanceFactor) {
                votes.append(try Vote(preferences: [.AltD, .AltE, .AltF]))
            }
            for _ in 1...(2 * performanceFactor) {
                votes.append(try Vote(preferences: [.AltE, .AltA, .AltD]))
            }
            for _ in 1...(1 * performanceFactor) {
                votes.append(try Vote(preferences: [.AltF, .AltB, .AltC]))
            }
        } catch {
            XCTFail("Failed to create votes")
        }
        
        self.measure {
            for vote in votes {
                withExtendedLifetime(vote.description) { }
            }
        }
    }
    
}
