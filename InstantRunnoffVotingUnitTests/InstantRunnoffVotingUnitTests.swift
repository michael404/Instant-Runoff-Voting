import XCTest

class InstantRunnoffVotingUnitTests: XCTestCase {
    
    /// Testing if expression throws the expected error in two steps. 
    /// First XCTAssertThrowsError to make sure that it thorws, and then a 
    /// do/try/catch-clause to make sure it returns the correct error
    func AssertThrowsExpectedError<T, E: Error & Equatable>(
        _ expression: @autoclosure () throws -> T, expectedError: E, file: StaticString = #file, line: UInt = #line) {
        
        XCTAssertThrowsError(try expression(), file: file, line: line)
        
        do {
            _ = try expression()
        } catch let thrownError as E {
            XCTAssertEqual(thrownError, expectedError, file: file, line: line)
        } catch {
            XCTFail("Threw wrong error type", file: file, line: line)
        }
        
    }
    
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
        
        AssertThrowsExpectedError(try VoteCounter(ballot: votes), expectedError: VoteError.unresolvableTie)
        
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
        
        AssertThrowsExpectedError(try VoteCounter(ballot: votes), expectedError: VoteError.unresolvableTie)
        
    }
    
    func testVoteWithNoOptions() {
        
        AssertThrowsExpectedError(try Vote(preferences: Array<TestOptions>()), expectedError: VoteError.noPreferencesInVote)
        
    }
    
    func testVoteRepeatedOptions() {
        
        AssertThrowsExpectedError(try Vote(preferences: [TestOptions.AltB, .AltB]), expectedError: VoteError.duplicatePreferencesInVote)
        
    }
    
}
