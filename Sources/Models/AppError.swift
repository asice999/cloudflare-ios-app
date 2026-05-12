import Foundation

enum AppError: LocalizedError {
    case missingToken
    case invalidResponse
    case server(String)
    case unknown

    var errorDescription: String? {
        switch self {
        case .missingToken:
            return "未找到 Cloudflare Token"
        case .invalidResponse:
            return "服务器响应异常"
        case .server(let message):
            return message
        case .unknown:
            return "未知错误"
        }
    }
}
