import SwiftUI

struct OverviewView: View {
    @StateObject private var viewModel = OverviewViewModel()

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.overview == nil {
                ProgressView("加载概览中…")
            } else if let errorMessage = viewModel.errorMessage, viewModel.overview == nil {
                ContentUnavailableView("加载失败", systemImage: "exclamationmark.triangle", description: Text(errorMessage))
            } else if let overview = viewModel.overview {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        header(overview: overview)
                        VStack(spacing: 12) {
                            metricCard(title: "域名数量", value: "\(overview.zoneCount)", subtitle: "已激活 \(overview.activeZoneCount)")
                            metricCard(title: "DNS 记录总数", value: "\(overview.totalDNSRecords)", subtitle: "已聚合前 10 个域名")
                            metricCard(title: "已代理记录", value: "\(overview.proxiedCount)", subtitle: "橙云代理开启")
                            metricCard(title: "仅 DNS 记录", value: "\(overview.dnsOnlyCount)", subtitle: "未开启代理")
                        }

                        Text("网站")
                            .font(.title3.bold())
                        NavigationLink(destination: ZoneListView()) {
                            infoRow(icon: "globe", title: overview.topZoneName ?? "暂无域名", subtitle: "点击查看域名与 DNS")
                        }
                        .buttonStyle(.plain)

                        Text("更多")
                            .font(.title3.bold())
                        VStack(spacing: 12) {
                            NavigationLink(destination: AnalyticsView()) {
                                infoRow(icon: "chart.xyaxis.line", title: "DNS 分析", subtitle: "真实记录类型、代理状态、TTL 分布")
                            }
                            NavigationLink(destination: ConnectorsView()) {
                                infoRow(icon: "link.badge.plus", title: "连接器", subtitle: "当前先保留页面骨架")
                            }
                            NavigationLink(destination: RoutesView()) {
                                infoRow(icon: "point.3.connected.trianglepath.dotted", title: "路由", subtitle: "当前先保留页面骨架")
                            }
                        }
                    }
                    .padding(16)
                }
                .background(Color(.systemGroupedBackground))
            }
        }
        .navigationTitle("概览")
        .task {
            if viewModel.overview == nil {
                await viewModel.load()
            }
        }
        .refreshable {
            await viewModel.load()
        }
    }

    private func header(overview: DashboardOverview) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Cloudflare 概览")
                .font(.largeTitle.bold())
            Text("基于你当前账户的真实 Zone 与 DNS 数据生成。")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private func metricCard(title: String, value: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            Text(value)
                .font(.system(size: 28, weight: .bold))
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func infoRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .frame(width: 28)
                .foregroundStyle(.blue)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(.tertiary)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
