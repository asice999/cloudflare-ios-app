import Foundation

struct Zone: Decodable, Identifiable {
    struct Plan: Decodable {
        let name: String?
    }

    let id: String
    let name: String
    let status: String?
    let paused: Bool?
    let type: String?
    let plan: Plan?
    let nameServers: [String]?

    enum CodingKeys: String, CodingKey {
        case id, name, status, paused, type, plan
        case nameServers = "name_servers"
    }
}
