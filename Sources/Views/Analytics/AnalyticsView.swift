import SwiftUI

struct AnalyticsView: View {
    @StateObject private var viewModel = AnalyticsViewModel()

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.analytics == nil {
                ProgressView("加载分析中…")
            } else if let errorMessage = viewModel.errorMessage, viewModel.analytics == nil {
                ContentUnavailableView("加载失败", systemImage: "exclamationmark.triangle", description: Text(errorMessage))
            } else if let analytics = viewModel.analytics {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("DNS 分析")
                            .font(.largeTitle.bold())
                        Text("以下内容基于当前账户前 10 个域名的真实 DNS 记录汇总。")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        statBlock(title: "记录总数", value: "\(analytics.totalRecords)")

                        section(title: "代理状态") {
                            VStack(spacing: 10) {
                                analyticsRow(name: "已代理", value: analytics.proxiedCount)
                                analyticsRow(name: "仅 DNS", value: analytics.dnsOnlyCount)
                                analyticsRow(name: "不支持代理", value: analytics.unsupportedProxyCount)
                            }
                        }

                        section(title: "记录类型分布") {
                            VStack(spacing: 10) {
                                ForEach(analytics.typeCounts.prefix(8)) { item in
                                    analyticsRow(name: item.name, value: item.value)
                                }
                            }
                        }

                        section(title: "TTL 分布") {
                            VStack(spacing: 10) {
                                ForEach(analytics.ttlSummary.prefix(6)) { item in
                                    analyticsRow(name: item.name, value: item.value)
                                }
                            }
                        }
                    }
                    .padding(16)
                }
                .background(Color(.systemGroupedBackground))
            }
        }
        .navigationTitle("分析")
        .task {
            if viewModel.analytics == nil {
                await viewModel.load()
            }
        }
        .refreshable {
            await viewModel.load()
        }
    }

    private func statBlock(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            Text(value)
                .font(.system(size: 30, weight: .bold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func section<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            content()
                .padding(16)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private func analyticsRow(name: String, value: Int) -> some View {
        HStack {
            Text(name)
            Spacer()
            Text("\(value)")
                .fontWeight(.semibold)
        }
        .font(.subheadline)
    }
}
