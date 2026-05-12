import SwiftUI

struct OverviewView: View {
    private let summaryCards: [DashboardSummaryCard] = [
        .init(title: "请求", value: "20.8万", delta: "+7,932.02%", color: .orange),
        .init(title: "带宽", value: "1.99 GB", delta: "+9,807.03%", color: .orange),
        .init(title: "访问量", value: "847", delta: "+556.59%", color: .orange),
        .init(title: "页面浏览量", value: "874", delta: "+537.96%", color: .orange)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                accountHeader
                summaryGrid
                statusCard
                sectionTitle("网站")
                NavigationLink(destination: ZoneListView()) {
                    infoRow(icon: "globe", title: "454735639.xyz", subtitle: "点击查看域名与 DNS")
                }
                .buttonStyle(.plain)

                sectionTitle("安全性")
                securityPanel

                sectionTitle("快捷入口")
                quickLinks
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
        }
        .background(
            LinearGradient(colors: [Color.orange.opacity(0.10), Color.white], startPoint: .top, endPoint: .center)
                .ignoresSafeArea()
        )
        .navigationTitle("概览")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var accountHeader: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(Color.white)
                .frame(width: 62, height: 62)
                .overlay(Image(systemName: "person.crop.circle").font(.system(size: 30)).foregroundStyle(.gray))
                .shadow(color: .black.opacity(0.06), radius: 8, y: 3)

            VStack(alignment: .leading, spacing: 4) {
                Text("Cloudflare 账户")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("454735639@qq.com's Account")
                    .font(.title3.weight(.semibold))
                    .lineLimit(1)
            }

            Spacer()

            NavigationLink(destination: SettingsView()) {
                Circle()
                    .fill(Color.white)
                    .frame(width: 52, height: 52)
                    .overlay(Image(systemName: "gearshape").font(.title3).foregroundStyle(.gray))
                    .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
            }
            .buttonStyle(.plain)
        }
    }

    private var summaryGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(summaryCards) { card in
                VStack(alignment: .leading, spacing: 14) {
                    Text(card.title)
                        .font(.headline)
                    Spacer(minLength: 6)
                    Text(card.value)
                        .font(.system(size: 27, weight: .bold))
                    Text(card.delta)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.green)
                        .clipShape(Capsule())
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(colors: [card.color.opacity(0.10), card.color.opacity(0.28)], startPoint: .top, endPoint: .bottom)
                        )
                        .frame(height: 54)
                        .overlay(alignment: .trailing) {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.title2)
                                .foregroundStyle(card.color.opacity(0.85))
                                .padding(.trailing, 10)
                        }
                }
                .padding(16)
                .frame(maxWidth: .infinity, minHeight: 180, alignment: .topLeading)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
            }
        }
    }

    private var statusCard: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(Color.green.opacity(0.16))
                .frame(width: 44, height: 44)
                .overlay(Circle().fill(Color.green).frame(width: 18, height: 18))

            VStack(alignment: .leading, spacing: 4) {
                Text("Cloudflare 状态")
                    .font(.headline)
                Text("运行正常，可继续管理网站与网络配置")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
    }

    private var securityPanel: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("加密请求数")
                        .font(.headline)
                    Text("20.8万")
                        .font(.system(size: 28, weight: .bold))
                    deltaChip(text: "+7,931.95%", color: .green)
                }
                Spacer()
                RoundedRectangle(cornerRadius: 14)
                    .fill(LinearGradient(colors: [Color.orange.opacity(0.08), Color.orange.opacity(0.22)], startPoint: .top, endPoint: .bottom))
                    .frame(width: 120, height: 120)
                    .overlay(Image(systemName: "waveform.path.ecg").font(.largeTitle).foregroundStyle(.orange))
            }

            HStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("加密请求率")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("100.00%")
                        .font(.title2.bold())
                    deltaChip(text: "-0.00%", color: .pink)
                }
                Spacer()
            }

            HStack(spacing: 10) {
                periodButton("天", active: false)
                periodButton("周", active: true)
                periodButton("月", active: false)
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
    }

    private var quickLinks: some View {
        VStack(spacing: 12) {
            NavigationLink(destination: AnalyticsView()) {
                featureRow(icon: "chart.xyaxis.line", title: "查看分析", subtitle: "请求、带宽、访问量与趋势")
            }
            NavigationLink(destination: ConnectorsView()) {
                featureRow(icon: "link.badge.plus", title: "连接器", subtitle: "Tunnel / Zero Trust / Origin 接入")
            }
            NavigationLink(destination: RoutesView()) {
                featureRow(icon: "point.3.connected.trianglepath.dotted", title: "路由", subtitle: "Workers Routes / Tunnel Routes")
            }
            NavigationLink(destination: SubscriptionView()) {
                featureRow(icon: "crown.fill", title: "升级订阅", subtitle: "按你给的橙色会员页风格展示")
            }
        }
        .buttonStyle(.plain)
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.title3.bold())
    }

    private func infoRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .frame(width: 34)
                .foregroundStyle(.black)
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
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
    }

    private func featureRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 14) {
            Circle()
                .fill(Color.orange.opacity(0.14))
                .frame(width: 48, height: 48)
                .overlay(Image(systemName: icon).foregroundStyle(.orange))
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
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
    }

    private func deltaChip(text: String, color: Color) -> some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(color)
            .clipShape(Capsule())
    }

    private func periodButton(_ title: String, active: Bool) -> some View {
        Text(title)
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(active ? Color(.systemGray5) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

private struct DashboardSummaryCard: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let delta: String
    let color: Color
}
