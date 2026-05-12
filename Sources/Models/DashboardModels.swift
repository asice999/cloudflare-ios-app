import Foundation

struct DashboardOverview {
    let zoneCount: Int
    let totalDNSRecords: Int
    let proxiedCount: Int
    let dnsOnlyCount: Int
    let topZoneName: String?
    let activeZoneCount: Int
}

struct DNSAnalytics {
    let totalRecords: Int
    let typeCounts: [DNSAnalyticsItem]
    let proxiedCount: Int
    let dnsOnlyCount: Int
    let unsupportedProxyCount: Int
    let ttlSummary: [DNSAnalyticsItem]
}

struct DNSAnalyticsItem: Identifiable {
    let id = UUID()
    let name: String
    let value: Int
}
