import Foundation

final class CloudflareAPIClient {
    private let baseURL = URL(string: "https://api.cloudflare.com/client/v4")!
    private let keychain = KeychainService()
    private let decoder = JSONDecoder()

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

    func fetchDNSRecords(zoneID: String) async throws -> [DNSRecord] {
        let request = try makeRequest(path: "zones/\(zoneID)/dns_records")
        let (data, _) = try await URLSession.shared.data(for: request)
        let decoded = try decoder.decode(CloudflareListResponse<DNSRecord>.self, from: data)
        guard decoded.success else {
            throw AppError.server(decoded.errors.first?.message ?? "获取 DNS 记录失败")
        }
        return decoded.result
    }

    func createDNSRecord(zoneID: String, payload: DNSRecordRequest) async throws {
        let body = try JSONEncoder().encode(payload)
        let request = try makeRequest(path: "zones/\(zoneID)/dns_records", method: "POST", body: body)
        let (data, _) = try await URLSession.shared.data(for: request)
        let decoded = try decoder.decode(CloudflareResponse<DNSRecord>.self, from: data)
        guard decoded.success else {
            throw AppError.server(decoded.errors.first?.message ?? "创建 DNS 记录失败")
        }
    }

    func updateDNSRecord(zoneID: String, recordID: String, payload: DNSRecordRequest) async throws {
        let body = try JSONEncoder().encode(payload)
        let request = try makeRequest(path: "zones/\(zoneID)/dns_records/\(recordID)", method: "PUT", body: body)
        let (data, _) = try await URLSession.shared.data(for: request)
        let decoded = try decoder.decode(CloudflareResponse<DNSRecord>.self, from: data)
        guard decoded.success else {
            throw AppError.server(decoded.errors.first?.message ?? "更新 DNS 记录失败")
        }
    }

    func deleteDNSRecord(zoneID: String, recordID: String) async throws {
        let request = try makeRequest(path: "zones/\(zoneID)/dns_records/\(recordID)", method: "DELETE")
        let (data, _) = try await URLSession.shared.data(for: request)
        let decoded = try decoder.decode(CloudflareResponse<DNSRecord>.self, from: data)
        guard decoded.success else {
            throw AppError.server(decoded.errors.first?.message ?? "删除 DNS 记录失败")
        }
    }
}
