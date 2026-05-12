import Foundation

struct DNSRecord: Decodable, Encodable, Identifiable {
    let id: String?
    let type: String
    let name: String
    let content: String
    let ttl: Int
    let proxied: Bool?

    enum CodingKeys: String, CodingKey {
        case id, type, name, content, ttl, proxied, data
    }

    init(id: String?, type: String, name: String, content: String, ttl: Int, proxied: Bool?) {
        self.id = id
        self.type = type
        self.name = name
        self.content = content
        self.ttl = ttl
        self.proxied = proxied
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decodeIfPresent(String.self, forKey: .id)
        type = try container.decodeIfPresent(String.self, forKey: .type) ?? "UNKNOWN"
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? "(未命名记录)"
        ttl = try container.decodeIfPresent(Int.self, forKey: .ttl) ?? 1
        proxied = try container.decodeIfPresent(Bool.self, forKey: .proxied)

        if let directContent = try container.decodeIfPresent(String.self, forKey: .content), !directContent.isEmpty {
            content = directContent
        } else if let dataObject = try? container.decodeIfPresent([String: String].self, forKey: .data),
                  let rendered = dataObject?.map({ "\($0.key)=\($0.value)" }).sorted().joined(separator: ", "),
                  !rendered.isEmpty {
            content = rendered
        } else {
            content = ""
        }
    }

    var displayProxiedText: String {
        if let proxied {
            return proxied ? "已代理" : "仅 DNS"
        }
        return "不支持代理"
    }

    var displayContent: String {
        content.isEmpty ? "无可展示内容" : content
    }
}

struct DNSRecordRequest: Encodable {
    let type: String
    let name: String
    let content: String
    let ttl: Int
    let proxied: Bool?
}
