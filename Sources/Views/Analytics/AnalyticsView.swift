import SwiftUI

struct AnalyticsView: View {
    private let cards: [AnalyticsCardItem] = [
        .init(title: "总请求", value: "--", trend: "等待接入接口", color: .blue),
        .init(title: "带宽", value: "--", trend: "等待接入接口", color: .green),
        .init(title: "威胁拦截", value: "--", trend: "等待接入接口", color: .orange),
        .init(title: "缓存命中率", value: "--", trend: "等待接入接口", color: .purple)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("数据分析")
                    .font(.largeTitle.bold())
                Text("第一版先提供分析模块框架，后续可接入 Cloudflare Analytics API。")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                ForEach(cards) { card in
                    VStack(alignment: .leading, spacing: 10) {
                        Text(card.title)
                            .font(.headline)
                        Text(card.value)
                            .font(.title.bold())
                        Text(card.trend)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(18)
                    .background(card.color.opacity(0.10))
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                }
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("分析")
    }
}

private struct AnalyticsCardItem: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let trend: String
    let color: Color
}
