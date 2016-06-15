public enum VoteError: ErrorProtocol {
    case noPreferencesInVote
    case optionPreferredMoreThanOnceInVote
    case votesAlreadyCounted
    case unresolvableTie
}
