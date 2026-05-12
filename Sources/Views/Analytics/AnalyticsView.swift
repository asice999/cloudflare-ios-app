import SwiftUI

struct AnalyticsView: View {
    private let cards: [AnalyticsMetricCard] = [
        .init(title: "总请求", value: "20.8万", growth: "+7,932.02%"),
        .init(title: "带宽", value: "1.99 GB", growth: "+9,807.03%"),
        .init(title: "访问量", value: "847", growth: "+556.59%"),
        .init(title: "页面浏览量", value: "874", growth: "+537.96%")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                premiumBanner
                actionRow(icon: "calendar.badge.plus", text: "更改分析的日期范围")
                actionRow(icon: "chart.bar.xaxis", text: "更多详细信息关于流量来源")
                actionRow(icon: "ticket", text: "在应用内启用遭受攻击模式和开发模式")
                actionRow(icon: "speedometer", text: "自定义数据刷新速率")
                actionRow(icon: "tv", text: "去除广告，享受无打扰体验")
                actionRow(icon: "arrow.triangle.2.circlepath", text: "您可以随时取消订阅")

                metricGrid

                NavigationLink(destination: SubscriptionView()) {
                    Text("查看订阅页")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(LinearGradient(colors: [.orange, .orange.opacity(0.8)], startPoint: .leading, endPoint: .trailing))
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                }
                .buttonStyle(.plain)
            }
            .padding(20)
        }
        .background(
            LinearGradient(colors: [Color.orange.opacity(0.12), Color.white], startPoint: .top, endPoint: .center)
                .ignoresSafeArea()
        )
        .navigationTitle("分析")
    }

    private var premiumBanner: some View {
        RoundedRectangle(cornerRadius: 28)
            .fill(LinearGradient(colors: [.orange.opacity(0.95), .orange], startPoint: .leading, endPoint: .trailing))
            .frame(height: 120)
            .overlay {
                Text("完美管理您的网站")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
            }
            .shadow(color: .orange.opacity(0.25), radius: 14, y: 8)
    }

    private func actionRow(icon: String, text: String) -> some View {
        HStack(spacing: 18) {
            Circle()
                .stroke(Color.orange.opacity(0.25), lineWidth: 1)
                .frame(width: 58, height: 58)
                .overlay(Image(systemName: icon).foregroundStyle(.orange).font(.title3))
            Text(text)
                .font(.title3)
                .foregroundStyle(.primary)
            Spacer()
        }
    }

    private var metricGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(cards) { card in
                VStack(alignment: .leading, spacing: 12) {
                    Text(card.title)
                        .font(.headline)
                    Text(card.value)
                        .font(.system(size: 28, weight: .bold))
                    Text(card.growth)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.green)
                        .clipShape(Capsule())
                    RoundedRectangle(cornerRadius: 12)
                        .fill(LinearGradient(colors: [Color.orange.opacity(0.06), Color.orange.opacity(0.22)], startPoint: .top, endPoint: .bottom))
                        .frame(height: 50)
                }
                .padding(16)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .shadow(color: .black.opacity(0.05), radius: 8, y: 3)
            }
        }
    }
}

private struct AnalyticsMetricCard: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let growth: String
}
