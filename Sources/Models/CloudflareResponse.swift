import Foundation

struct CloudflareResponse<T: Decodable>: Decodable {
    let success: Bool
    let errors: [CloudflareAPIError]
    let messages: [CloudflareMessage]
    let result: T
}

struct CloudflareListResponse<T: Decodable>: Decodable {
    let success: Bool
    let errors: [CloudflareAPIError]
    let messages: [CloudflareMessage]
    let result: [T]
}

struct CloudflareAPIError: Decodable, Identifiable, Error {
    let code: Int
    let message: String
    var id: Int { code }
}

struct CloudflareMessage: Decodable {
    let code: Int?
    let message: String?
}
