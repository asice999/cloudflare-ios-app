import Foundation

struct DNSRecord: Decodable, Encodable, Identifiable {
    let id: String?
    let type: String
    let name: String
    let content: String
    let ttl: Int
    let proxied: Bool?

    var displayProxiedText: String {
        if let proxied {
            return proxied ? "已代理" : "仅 DNS"
        }
        return "不支持代理"
    }
}

struct DNSRecordRequest: Encodable {
    let type: String
    let name: String
    let content: String
    let ttl: Int
    let proxied: Bool?
}
