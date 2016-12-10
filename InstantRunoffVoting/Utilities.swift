public enum VoteError: Error {
    case noPreferencesInVote
    case optionPreferredMoreThanOnceInVote
    case votesAlreadyCounted
    case unresolvableTie
}

extension Array where Iterator.Element: Hashable {
    
    func hasUniqueElements() -> Bool {
        return Set(self).count == self.count
    }
    
}
