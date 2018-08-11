// TODO: change this to `ID<Team>`, probably
struct TeamID: Newtype, Decodable, Hashable {
    let rawValue: String
}
