import SwiftUI

struct OverviewView: View {
    private let stats: [OverviewStat] = [
        .init(title: "域名", value: "--", icon: "globe.badge.chevron.backward", color: .blue),
        .init(title: "DNS 记录", value: "--", icon: "list.bullet.rectangle", color: .green),
        .init(title: "连接器", value: "--", icon: "link", color: .orange),
        .init(title: "路由规则", value: "--", icon: "point.3.connected.trianglepath.dotted", color: .purple)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                    ForEach(stats) { stat in
                        StatCard(stat: stat)
                    }
                }
                quickEntrySection
                activitySection
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("概览")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Cloudflare 控制台")
                .font(.largeTitle.bold())
            Text("把常用的 DNS、分析、连接器和路由管理集中到手机里。")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var quickEntrySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("快捷入口")
                .font(.headline)
            VStack(spacing: 12) {
                QuickEntryRow(title: "管理 DNS 记录", subtitle: "查看和修改域名解析", icon: "network")
                QuickEntryRow(title: "查看数据分析", subtitle: "流量、带宽与请求趋势", icon: "chart.line.uptrend.xyaxis")
                QuickEntryRow(title: "管理连接器", subtitle: "Zero Trust / Tunnel 接入概览", icon: "link.badge.plus")
                QuickEntryRow(title: "检查路由", subtitle: "Workers / Tunnel / 网络转发", icon: "arrow.triangle.branch")
            }
        }
    }

    private var activitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("最近状态")
                .font(.headline)
            VStack(alignment: .leading, spacing: 10) {
                StatusLine(text: "已接入 Cloudflare Token 登录")
                StatusLine(text: "已支持 Zone / DNS 管理")
                StatusLine(text: "分析、连接器、路由模块已加入第一版界面")
            }
            .padding(16)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
    }
}

private struct OverviewStat: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let icon: String
    let color: Color
}

private struct StatCard: View {
    let stat: OverviewStat

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: stat.icon)
                .font(.title3)
                .foregroundStyle(stat.color)
            Text(stat.title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(stat.value)
                .font(.title2.bold())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

private struct QuickEntryRow: View {
    let title: String
    let subtitle: String
    let icon: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 38, height: 38)
                .background(Color.blue.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(.tertiary)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

private struct StatusLine: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
            Text(text)
                .font(.subheadline)
        }
    }
}
