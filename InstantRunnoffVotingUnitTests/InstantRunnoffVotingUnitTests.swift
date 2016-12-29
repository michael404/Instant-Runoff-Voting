import XCTest

class InstantRunnoffVotingUnitTests: XCTestCase {
    
    enum TestOptions: String, Votable {
        case AltA = "A", AltB = "B", AltC = "C", AltD = "D", AltE = "E", AltF = "F"
        var description: String { return self.rawValue }
    }
    
    func testOneRoundVote() {
        var votes: [Vote<TestOptions>] = []
        do {
            votes.append(try Vote(preferences: [.AltA, .AltB, .AltC]))
            votes.append(try Vote(preferences: [.AltA, .AltB, .AltC]))
            votes.append(try Vote(preferences: [.AltA, .AltB, .AltC, .AltD]))
            votes.append(try Vote(preferences: [.AltA, .AltB, .AltC]))
            votes.append(try Vote(preferences: [.AltA, .AltC, .AltB]))
            votes.append(try Vote(preferences: [.AltB, .AltA]))
        } catch {
            XCTFail("Failed to create votes")
        }
        
        let voteCounter = try! VoteCounter(ballot: votes)
        
        print(voteCounter)
        
        XCTAssertEqual(voteCounter.winner, TestOptions.AltA)
        
        let results = voteCounter.results
        
        XCTAssertEqual(results.count, 1)
        
        XCTAssertEqual(results[0].count, 2)
        XCTAssertEqual(results[0][.AltA], 5)
        XCTAssertEqual(results[0][.AltB], 1)
    }
    
    func testTwoRoundVote() {
        var votes: [Vote<TestOptions>] = []
        
        do {
            votes.append(try Vote(preferences: [.AltA]))
            votes.append(try Vote(preferences: [.AltA]))
            votes.append(try Vote(preferences: [.AltA]))
            
            votes.append(try Vote(preferences: [.AltB]))
            votes.append(try Vote(preferences: [.AltB]))
            
            votes.append(try Vote(preferences: [.AltC]))
        } catch {
            XCTFail("Failed to create votes")
        }
        
        let voteCounter = try! VoteCounter(ballot: votes)
        
        print(voteCounter)
        XCTAssertEqual(voteCounter.winner, TestOptions.AltA)
        
        let results = voteCounter.results
        
        XCTAssertEqual(results.count, 2)
        
        XCTAssertEqual(results[0].count, 3)
        XCTAssertEqual(results[0][.AltA], 3)
        XCTAssertEqual(results[0][.AltB], 2)
        XCTAssertEqual(results[0][.AltC], 1)
        
        XCTAssertEqual(results[1].count, 2)
        XCTAssertEqual(results[1][.AltA], 3)
        XCTAssertEqual(results[1][.AltB], 2)
    }
    
    func testFourRoundVote() {
        var votes: [Vote<TestOptions>] = []
        
        do {
            for _ in 1...7 {
                votes.append(try Vote(preferences: [.AltA]))
            }
            for _ in 1...6 {
                votes.append(try Vote(preferences: [.AltB]))
            }
            for _ in 1...5 {
                votes.append(try Vote(preferences: [.AltC]))
            }
            for _ in 1...4 {
                votes.append(try Vote(preferences: [.AltD, .AltE]))
            }
            votes.append(try Vote(preferences: [.AltE, .AltF, .AltA]))
            votes.append(try Vote(preferences: [.AltF, .AltB]))
        } catch {
            XCTFail("Failed to create votes")
        }
        
        let voteCounter = try! VoteCounter(ballot: votes)
        
        print(voteCounter)
        XCTAssertEqual(voteCounter.winner, TestOptions.AltA)
        
        let results = voteCounter.results
        
        XCTAssertEqual(results.count, 4)
        
        XCTAssertEqual(results[0].count, 6)
        XCTAssertEqual(results[0][.AltA], 7)
        XCTAssertEqual(results[0][.AltB], 6)
        XCTAssertEqual(results[0][.AltC], 5)
        XCTAssertEqual(results[0][.AltD], 4)
        XCTAssertEqual(results[0][.AltE], 1)
        XCTAssertEqual(results[0][.AltF], 1)
        
        XCTAssertEqual(results[1].count, 4)
        XCTAssertEqual(results[1][.AltA], 8)
        XCTAssertEqual(results[1][.AltB], 7)
        XCTAssertEqual(results[1][.AltC], 5)
        XCTAssertEqual(results[1][.AltD], 4)
        
        XCTAssertEqual(results[2].count, 3)
        XCTAssertEqual(results[2][.AltA], 8)
        XCTAssertEqual(results[2][.AltB], 7)
        XCTAssertEqual(results[2][.AltC], 5)
        
        XCTAssertEqual(results[3].count, 2)
        XCTAssertEqual(results[3][.AltA], 8)
        XCTAssertEqual(results[3][.AltB], 7)
    }
    
    func testVoteWithStringOptions() {
        
        var votes: [Vote<String>] = []
        
        do {
            votes.append(try Vote(preferences: ["Alt A", "Alt B", "Alt C", "Alt D"]))
            votes.append(try Vote(preferences: ["Alt A", "Alt B"]))
            votes.append(try Vote(preferences: ["Alt A", "Alt B"]))
            votes.append(try Vote(preferences: ["Alt B"]))
            votes.append(try Vote(preferences: ["Alt B"]))
            votes.append(try Vote(preferences: ["Alt C", "Alt A"]))
        } catch {
            XCTFail("Failed to create votes")
        }
        
        let voteCounter = try! VoteCounter(ballot: votes)
        
        print(voteCounter)
        XCTAssertEqual(voteCounter.winner, "Alt A")
        
        let results = voteCounter.results
        
        XCTAssertEqual(results.count, 2)
        
        XCTAssertEqual(results[0].count, 3)
        XCTAssertEqual(results[0]["Alt A"], 3)
        XCTAssertEqual(results[0]["Alt B"], 2)
        XCTAssertEqual(results[0]["Alt C"], 1)
        
        XCTAssertEqual(results[1].count, 2)
        XCTAssertEqual(results[1]["Alt A"], 4)
        XCTAssertEqual(results[1]["Alt B"], 2)
    }
    
    func testTwoWayResolvableTie() {
        var votes: [Vote<TestOptions>] = []
        
        do {
            votes.append(try Vote(preferences: [.AltA, .AltC]))
            votes.append(try Vote(preferences: [.AltA]))
            votes.append(try Vote(preferences: [.AltA]))
            votes.append(try Vote(preferences: [.AltA]))
            votes.append(try Vote(preferences: [.AltA, .AltD]))
            
            votes.append(try Vote(preferences: [.AltB]))
            votes.append(try Vote(preferences: [.AltB]))
            votes.append(try Vote(preferences: [.AltB]))
            votes.append(try Vote(preferences: [.AltB, .AltC]))
            
            votes.append(try Vote(preferences: [.AltC]))
            votes.append(try Vote(preferences: [.AltD]))
        } catch {
            XCTFail("Failed to create votes")
        }
        
        let voteCounter = try! VoteCounter(ballot: votes)
        
        print(voteCounter)
        XCTAssertEqual(voteCounter.winner, TestOptions.AltA)
        
        let results = voteCounter.results
        
        XCTAssertEqual(results.count, 2)
        
        XCTAssertEqual(results[0].count, 4)
        XCTAssertEqual(results[0][.AltA], 5)
        XCTAssertEqual(results[0][.AltB], 4)
        XCTAssertEqual(results[0][.AltC], 1)
        XCTAssertEqual(results[0][.AltD], 1)
        
        XCTAssertEqual(results[1].count, 2)
        XCTAssertEqual(results[1][.AltA], 5)
        XCTAssertEqual(results[1][.AltB], 4)
        
    }
    
    func testThreeWayResolvableTie() {
        var votes: [Vote<TestOptions>] = []
        
        do {
            votes.append(try Vote(preferences: [.AltA]))
            votes.append(try Vote(preferences: [.AltA]))
            
            votes.append(try Vote(preferences: [.AltB]))
            votes.append(try Vote(preferences: [.AltB]))
            
            votes.append(try Vote(preferences: [.AltC]))
            votes.append(try Vote(preferences: [.AltC]))
            
            for _ in 1...8 {
                votes.append(try Vote(preferences: [.AltD]))
            }
            
            for _ in 1...7 {
                votes.append(try Vote(preferences: [.AltE]))
            }
        } catch {
            XCTFail("Failed to create votes")
        }
        
        let voteCounter = try! VoteCounter(ballot: votes)
        
        print(voteCounter)
        XCTAssertEqual(voteCounter.winner, TestOptions.AltD)
        
        let results = voteCounter.results
        
        XCTAssertEqual(results.count, 2)
        
        XCTAssertEqual(results[0].count, 5)
        XCTAssertEqual(results[0][.AltA], 2)
        XCTAssertEqual(results[0][.AltB], 2)
        XCTAssertEqual(results[0][.AltC], 2)
        XCTAssertEqual(results[0][.AltD], 8)
        XCTAssertEqual(results[0][.AltE], 7)
        
        
        XCTAssertEqual(results[1].count, 2)
        XCTAssertEqual(results[1][.AltD], 8)
        XCTAssertEqual(results[0][.AltE], 7)
        
    }
    
    func testTwoWayUnresolvableTie() {
        var votes: [Vote<TestOptions>] = []
        
        do {
            votes.append(try Vote(preferences: [.AltA, .AltC]))
            votes.append(try Vote(preferences: [.AltA]))
            votes.append(try Vote(preferences: [.AltA]))
            votes.append(try Vote(preferences: [.AltA, .AltD]))
            
            votes.append(try Vote(preferences: [.AltB]))
            votes.append(try Vote(preferences: [.AltB]))
            votes.append(try Vote(preferences: [.AltB]))
            votes.append(try Vote(preferences: [.AltB, .AltC]))
        } catch {
            XCTFail("Failed to create votes")
        }
        
        // Testing this in two steps. First "try?" to make sure that this fails, and
        // then a do/try/catch-clause to make sure it returns the correct error
        
        XCTAssertNil(try? VoteCounter(ballot: votes))
        
        do {
            let _ = try VoteCounter(ballot: votes)
        } catch let e as VoteError {
            XCTAssertEqual(e, VoteError.unresolvableTie)
        } catch {
            XCTFail("Unresolvable tie threw wrong error type")
        }
        
    }
    
    func testFourWayUnresolvableTie() {
        var votes: [Vote<TestOptions>] = []
        
        do {
            votes.append(try Vote(preferences: [.AltA, .AltC]))
            votes.append(try Vote(preferences: [.AltB]))
            votes.append(try Vote(preferences: [.AltC]))
            votes.append(try Vote(preferences: [.AltD, .AltB]))
        } catch {
            XCTFail("Failed to create votes")
        }
        
        // Testing this in two steps. First "try?" to make sure that this fails, and
        // then a do/try/catch-clause to make sure it returns the correct error
        
        XCTAssertNil(try? VoteCounter(ballot: votes))
        
        do {
            let _ = try VoteCounter(ballot: votes)
        } catch let e as VoteError {
            XCTAssertEqual(e, VoteError.unresolvableTie)
        } catch {
            XCTFail("Unresolvable tie threw wrong error type")
        }
    }
    
    func testVoteWithNoOptions() {
        
        // Testing this in two steps. First "try?" to make sure that this fails, and
        // then a do/try/catch-clause to make sure it returns the correct error
        
        XCTAssertNil(try? Vote(preferences: Array<TestOptions>()))
        
        do {
            let _ = try Vote(preferences: Array<TestOptions>())
        } catch let e as VoteError {
            XCTAssertEqual(e, VoteError.noPreferencesInVote)
        } catch {
            XCTFail("testVoteWithNoOptions threw wrong error type")
        }
        
    }
    
    func testVoteRepeatedOptions() {
        
        // Testing this in two steps. First "try?" to make sure that this fails, and
        // then a do/try/catch-clause to make sure it returns the correct error
        
        XCTAssertNil(try? Vote(preferences: [TestOptions.AltB, .AltB]))

        do {
            let _ =
            try Vote(preferences: [TestOptions.AltB, .AltB])
        } catch let e as VoteError {
            XCTAssertEqual(e, VoteError.optionPreferredMoreThanOnceInVote)
        } catch {
            XCTFail("testVoteRepeatedOptions threw wrong error type")
        }
        
    }
    
}
