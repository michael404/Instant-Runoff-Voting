//
//  InstantRunnoffVotingPerformanceTest.swift
//  InstantRunoffVoting
//
//  Created by Michael Holmgren on 2016-01-11.
//  Copyright © 2016 Michael Holmgren. All rights reserved.
//

import XCTest

extension Int: Votable {
}

class InstantRunnoffVotingPerformanceTest: XCTestCase {
    
    enum TestOptions: String, Votable {
        case AltA = "A"
        case AltB = "B"
        case AltC = "C"
        case AltD = "D"
        case AltE = "E"
        case AltF = "F"
        
        var description: String {
            get {
                return self.rawValue
            }
        }
    }
    
    func testPerformanceOfFourRoundVote() {
        
        var votes: [Vote<TestOptions>] = []
        
        let performanceFactor = 200
        
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
        
        self.measureBlock {
            let voteCounter = try! VoteCounter(ballot: votes)
            let _ = voteCounter.results
        }
    }
    
    func testPerformanceWithManyOptions() {
        
        var votes: [Vote<Int>] = []
        
        do {
            for i in 1...70 {
                for _ in 1...i {
                    votes.append(try Vote(preferences: [i]))
                }
            }
        } catch {
            XCTFail("Failed to create votes")
        }
        
        self.measureBlock {
            let voteCounter = try! VoteCounter(ballot: votes)
            let _ = voteCounter.results
        }
    }
    
    func testPerformanceOfVoteValidation() {
        
        var votes: [Vote<TestOptions>] = []
        
        let performanceFactor = 800
        
        self.measureBlock {
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
        }
        
    }
    
    
}
