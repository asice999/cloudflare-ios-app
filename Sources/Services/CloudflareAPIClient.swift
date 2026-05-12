import Foundation

final class CloudflareAPIClient {
    private let baseURL = URL(string: "https://api.cloudflare.com/client/v4")!
    private let keychain = KeychainService()
    private let decoder = JSONDecoder()

    private struct RawCloudflareListResponse: Decodable {
        let success: Bool
        let errors: [CloudflareAPIError]
        let messages: [CloudflareMessage]
        let result: [JSONValue]
    }

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
        let (data, _) = try await URLSession.shared.data(for: request)
        let decoded = try decoder.decode(RawCloudflareListResponse.self, from: data)
        guard decoded.success else {
            throw AppError.server(decoded.errors.first?.message ?? "获取 DNS 记录失败")
        }

        var items: [DNSRecord] = []
        var skippedCount = 0

        for raw in decoded.result {
            do {
                let itemData = try JSONEncoder().encode(raw)
                let record = try decoder.decode(DNSRecord.self, from: itemData)
                items.append(record)
            } catch {
                skippedCount += 1
            }
        }

        return PartialDecodeResult(items: items, skippedCount: skippedCount)
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
