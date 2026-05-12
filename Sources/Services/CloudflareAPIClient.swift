import Foundation

final class CloudflareAPIClient {
    private let baseURL = URL(string: "https://api.cloudflare.com/client/v4")!
    private let keychain = KeychainService()
    private let decoder = JSONDecoder()

    private struct RawCloudflareObjectResponse: Decodable {
        let success: Bool
        let errors: [CloudflareAPIError]
        let messages: [CloudflareMessage]
        let result: JSONValue
    }

    private func makeRequest(path: String, method: String = "GET", body: Data? = nil) throws -> URLRequest {
        guard let token = keychain.readToken(), !token.isEmpty else {
            throw AppError.missingToken
        }

        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        return request
    }

    func verifyToken() async throws {
        let request = try makeRequest(path: "user/tokens/verify")
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw AppError.invalidResponse
        }
    }

    func fetchZones() async throws -> [Zone] {
        let request = try makeRequest(path: "zones")
        let (data, _) = try await URLSession.shared.data(for: request)
        let decoded = try decoder.decode(CloudflareListResponse<Zone>.self, from: data)
        guard decoded.success else {
            throw AppError.server(decoded.errors.first?.message ?? "获取域名失败")
        }
        return decoded.result
    }

    func fetchDNSRecords(zoneID: String) async throws -> PartialDecodeResult<DNSRecord> {
        let request = try makeRequest(path: "zones/\(zoneID)/dns_records")
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw AppError.server("获取 DNS 记录失败：HTTP 状态异常")
        }

        guard
            let root = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let success = root["success"] as? Bool
        else {
            throw AppError.server("获取 DNS 记录失败：返回格式异常")
        }

        if !success {
            if let errors = root["errors"] as? [[String: Any]],
               let message = errors.first?["message"] as? String {
                throw AppError.server(message)
            }
            throw AppError.server("获取 DNS 记录失败")
        }

        guard let result = root["result"] as? [[String: Any]] else {
            throw AppError.server("获取 DNS 记录失败：result 缺失")
        }

        var items: [DNSRecord] = []
        var skippedCount = 0

        for record in result {
            let id = record["id"] as? String
            let type = (record["type"] as? String) ?? "UNKNOWN"
            let name = (record["name"] as? String) ?? "(未命名记录)"
            let ttl = (record["ttl"] as? Int) ?? 1
            let proxied = record["proxied"] as? Bool

            var content = (record["content"] as? String) ?? ""

            if content.isEmpty, let dataObject = record["data"] as? [String: Any] {
                content = dataObject
                    .map { "\($0.key)=\(String(describing: $0.value))" }
                    .sorted()
                    .joined(separator: ", ")
            }

            if content.isEmpty, type == "UNKNOWN" && name == "(未命名记录)" {
                skippedCount += 1
                continue
            }

            items.append(DNSRecord(id: id, type: type, name: name, content: content, ttl: ttl, proxied: proxied))
        }

        return PartialDecodeResult(items: items, skippedCount: skippedCount)
    }

    func fetchDashboardOverview() async throws -> DashboardOverview {
        let zones = try await fetchZones()
        var totalDNSRecords = 0
        var proxiedCount = 0
        var dnsOnlyCount = 0

        for zone in zones.prefix(10) {
            let result = try await fetchDNSRecords(zoneID: zone.id)
            totalDNSRecords += result.items.count
            proxiedCount += result.items.filter { $0.proxied == true }.count
            dnsOnlyCount += result.items.filter { $0.proxied == false }.count
        }

        let activeZoneCount = zones.filter { ($0.status ?? "").lowercased() == "active" }.count

        return DashboardOverview(
            zoneCount: zones.count,
            totalDNSRecords: totalDNSRecords,
            proxiedCount: proxiedCount,
            dnsOnlyCount: dnsOnlyCount,
            topZoneName: zones.first?.name,
            activeZoneCount: activeZoneCount
        )
    }

    func fetchDNSAnalytics() async throws -> DNSAnalytics {
        let zones = try await fetchZones()
        var allRecords: [DNSRecord] = []

        for zone in zones.prefix(10) {
            let result = try await fetchDNSRecords(zoneID: zone.id)
            allRecords.append(contentsOf: result.items)
        }

        let typeMap = Dictionary(grouping: allRecords, by: { $0.type.uppercased() })
            .map { DNSAnalyticsItem(name: $0.key, value: $0.value.count) }
            .sorted { $0.value > $1.value }

        let ttlMap = Dictionary(grouping: allRecords, by: { String($0.ttl) })
            .map { DNSAnalyticsItem(name: "TTL \($0.key)", value: $0.value.count) }
            .sorted { $0.value > $1.value }

        let proxiedCount = allRecords.filter { $0.proxied == true }.count
        let dnsOnlyCount = allRecords.filter { $0.proxied == false }.count
        let unsupportedProxyCount = allRecords.filter { $0.proxied == nil }.count

        return DNSAnalytics(
            totalRecords: allRecords.count,
            typeCounts: typeMap,
            proxiedCount: proxiedCount,
            dnsOnlyCount: dnsOnlyCount,
            unsupportedProxyCount: unsupportedProxyCount,
            ttlSummary: ttlMap
        )
    }

    func createDNSRecord(zoneID: String, payload: DNSRecordRequest) async throws {
        let body = try JSONEncoder().encode(payload)
        let request = try makeRequest(path: "zones/\(zoneID)/dns_records", method: "POST", body: body)
        let (data, _) = try await URLSession.shared.data(for: request)
        let decoded = try decoder.decode(RawCloudflareObjectResponse.self, from: data)
        guard decoded.success else {
            throw AppError.server(decoded.errors.first?.message ?? "创建 DNS 记录失败")
        }
    }

    func updateDNSRecord(zoneID: String, recordID: String, payload: DNSRecordRequest) async throws {
        let body = try JSONEncoder().encode(payload)
        let request = try makeRequest(path: "zones/\(zoneID)/dns_records/\(recordID)", method: "PUT", body: body)
        let (data, _) = try await URLSession.shared.data(for: request)
        let decoded = try decoder.decode(RawCloudflareObjectResponse.self, from: data)
        guard decoded.success else {
            throw AppError.server(decoded.errors.first?.message ?? "更新 DNS 记录失败")
        }
    }

    func deleteDNSRecord(zoneID: String, recordID: String) async throws {
        let request = try makeRequest(path: "zones/\(zoneID)/dns_records/\(recordID)", method: "DELETE")
        let (data, _) = try await URLSession.shared.data(for: request)
        let decoded = try decoder.decode(RawCloudflareObjectResponse.self, from: data)
        guard decoded.success else {
            throw AppError.server(decoded.errors.first?.message ?? "删除 DNS 记录失败")
        }
    }
}

private enum JSONValue: Codable {
    case string(String)
    case number(Double)
    case bool(Bool)
    case object([String: JSONValue])
    case array([JSONValue])
    case null

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .null
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode(Double.self) {
            self = .number(value)
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode([String: JSONValue].self) {
            self = .object(value)
        } else if let value = try? container.decode([JSONValue].self) {
            self = .array(value)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported JSON value")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value):
            try container.encode(value)
        case .number(let value):
            try container.encode(value)
        case .bool(let value):
            try container.encode(value)
        case .object(let value):
            try container.encode(value)
        case .array(let value):
            try container.encode(value)
        case .null:
            try container.encodeNil()
        }
    }
}
