import SwiftUI

struct DNSRecordListView: View {
    let zone: Zone
    @StateObject private var viewModel = DNSRecordListViewModel()
    @State private var isPresentingCreate = false
    @State private var searchText = ""

    private var filteredRecords: [DNSRecord] {
        let keyword = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !keyword.isEmpty else { return viewModel.records }
        return viewModel.records.filter { record in
            record.name.localizedCaseInsensitiveContains(keyword) ||
            record.type.localizedCaseInsensitiveContains(keyword) ||
            record.content.localizedCaseInsensitiveContains(keyword)
        }
    }

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.records.isEmpty {
                ProgressView("加载 DNS 中…")
            } else if let errorMessage = viewModel.errorMessage, viewModel.records.isEmpty {
                ContentUnavailableView("加载失败", systemImage: "exclamationmark.triangle", description: Text(errorMessage))
            } else if viewModel.records.isEmpty {
                ContentUnavailableView("暂无 DNS 记录", systemImage: "list.bullet.rectangle")
            } else {
                ScrollView {
                    VStack(spacing: 14) {
                        if let warningMessage = viewModel.warningMessage {
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "exclamationmark.circle")
                                    .foregroundStyle(.orange)
                                Text(warningMessage)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Spacer()
                            }
                            .padding(14)
                            .background(Color.orange.opacity(0.10))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }

                        ForEach(filteredRecords) { record in
                            NavigationLink(destination: DNSRecordFormView(zone: zone, existingRecord: record)) {
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack {
                                        Text(record.type)
                                            .font(.caption.weight(.semibold))
                                            .padding(.horizontal, 9)
                                            .padding(.vertical, 5)
                                            .background(Color.blue.opacity(0.12))
                                            .clipShape(Capsule())
                                        Text(record.displayProxiedText)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        Spacer()
                                        Text("TTL \(record.ttl)")
                                            .font(.caption)
                                            .foregroundStyle(.tertiary)
                                    }
                                    Text(record.name)
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                    Text(record.displayContent)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .padding(16)
                                .background(Color(.systemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                if let id = record.id {
                                    Button(role: .destructive) {
                                        Task { await viewModel.deleteRecord(zoneID: zone.id, recordID: id) }
                                    } label: {
                                        Label("删除", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                    .padding(20)
                }
                .background(Color(.systemGroupedBackground))
                .refreshable {
                    await viewModel.loadRecords(zoneID: zone.id)
                }
                .searchable(text: $searchText, prompt: "搜索记录")
            }
        }
        .navigationTitle(zone.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isPresentingCreate = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $isPresentingCreate) {
            NavigationStack {
                DNSRecordFormView(zone: zone, existingRecord: nil)
            }
        }
        .task {
            if viewModel.records.isEmpty {
                await viewModel.loadRecords(zoneID: zone.id)
            }
        }
    }
}
