import SwiftUI

struct ZoneListView: View {
    @StateObject private var viewModel = ZoneListViewModel()

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.zones.isEmpty {
                ProgressView("加载域名中…")
            } else if let errorMessage = viewModel.errorMessage, viewModel.zones.isEmpty {
                ContentUnavailableView("加载失败", systemImage: "exclamationmark.triangle", description: Text(errorMessage))
            } else if viewModel.zones.isEmpty {
                ContentUnavailableView("暂无域名", systemImage: "globe")
            } else {
                List(viewModel.zones) { zone in
                    NavigationLink(destination: DNSRecordListView(zone: zone)) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(zone.name)
                                .font(.headline)
                            HStack {
                                Text(zone.status ?? "未知状态")
                                if let plan = zone.plan?.name {
                                    Text("· \(plan)")
                                }
                            }
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        }
                    }
                }
                .refreshable {
                    await viewModel.loadZones()
                }
            }
        }
        .navigationTitle("域名")
        .task {
            if viewModel.zones.isEmpty {
                await viewModel.loadZones()
            }
        }
    }
}
