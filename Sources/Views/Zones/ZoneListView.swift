import SwiftUI

struct ZoneListView: View {
    @StateObject private var viewModel = ZoneListViewModel()
    @State private var searchText = ""

    private var filteredZones: [Zone] {
        let keyword = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !keyword.isEmpty else { return viewModel.zones }
        return viewModel.zones.filter { zone in
            zone.name.localizedCaseInsensitiveContains(keyword) ||
            (zone.status ?? "").localizedCaseInsensitiveContains(keyword) ||
            (zone.plan?.name ?? "").localizedCaseInsensitiveContains(keyword)
        }
    }

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.zones.isEmpty {
                ProgressView("加载域名中…")
            } else if let errorMessage = viewModel.errorMessage, viewModel.zones.isEmpty {
                ContentUnavailableView("加载失败", systemImage: "exclamationmark.triangle", description: Text(errorMessage))
            } else if viewModel.zones.isEmpty {
                ContentUnavailableView("暂无域名", systemImage: "globe")
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        SearchBarPlaceholder(text: searchText.isEmpty ? "搜索域名、状态或套餐" : searchText)
                            .onTapGesture { }

                        ForEach(filteredZones) { zone in
                            NavigationLink(destination: DNSRecordListView(zone: zone)) {
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack {
                                        Text(zone.name)
                                            .font(.headline)
                                            .foregroundStyle(.primary)
                                        Spacer()
                                        Text(zone.status ?? "未知")
                                            .font(.caption)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.green.opacity(0.12))
                                            .clipShape(Capsule())
                                    }
                                    HStack(spacing: 8) {
                                        Label(zone.plan?.name ?? "未识别套餐", systemImage: "shippingbox")
                                        if let ns = zone.nameServers?.first {
                                            Label(ns, systemImage: "server.rack")
                                                .lineLimit(1)
                                        }
                                    }
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                }
                                .padding(16)
                                .background(Color(.systemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(20)
                }
                .background(Color(.systemGroupedBackground))
                .refreshable {
                    await viewModel.loadZones()
                }
                .searchable(text: $searchText, prompt: "搜索域名")
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
