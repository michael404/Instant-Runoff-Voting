public enum VoteError: ErrorProtocol {
    case NoPreferencesInVote
    case OptionPreferredMoreThanOnceInVote
    case VotesAlreadyCounted
    case UnresolvableTie
}