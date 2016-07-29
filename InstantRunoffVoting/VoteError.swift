public enum VoteError: Error {
    case noPreferencesInVote
    case optionPreferredMoreThanOnceInVote
    case votesAlreadyCounted
    case unresolvableTie
}
