struct Target {
    let source: Source
    let user: ID<User>
    let timestamp: Timestamp
}

extension Message {
    var target: Target {
        return Target(source: source, user: user, timestamp: timestamp)
    }
}
