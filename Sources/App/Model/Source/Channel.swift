public struct Channel: Decodable {
    let name: String
    let id: ID<Channel>
    let creator: ID<User>
    let created: UnixTimestamp
    let members: [ID<User>]
}
