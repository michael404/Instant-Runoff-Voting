public enum VoteError: ErrorType {
    case NoPreferencesInVote
    case OptionPreferredMoreThanOnceInVote
    case VotesAlreadyCounted
    case UnresolvableTie
}