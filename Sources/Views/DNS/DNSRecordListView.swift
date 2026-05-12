import SwiftUI

struct DNSRecordListView: View {
    let zone: Zone
    @StateObject private var viewModel = DNSRecordListViewModel()
    @State private var isPresentingCreate = false

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.records.isEmpty {
                ProgressView("加载 DNS 中…")
            } else if let errorMessage = viewModel.errorMessage, viewModel.records.isEmpty {
                ContentUnavailableView("加载失败", systemImage: "exclamationmark.triangle", description: Text(errorMessage))
            } else if viewModel.records.isEmpty {
                ContentUnavailableView("暂无 DNS 记录", systemImage: "list.bullet.rectangle")
            } else {
                List {
                    ForEach(viewModel.records) { record in
                        NavigationLink(destination: DNSRecordFormView(zone: zone, existingRecord: record)) {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(record.type)
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.blue.opacity(0.12))
                                        .clipShape(Capsule())
                                    Text(record.displayProxiedText)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Text(record.name)
                                    .font(.headline)
                                Text(record.content)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Text("TTL: \(record.ttl)")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                        .swipeActions {
                            if let id = record.id {
                                Button("删除", role: .destructive) {
                                    Task { await viewModel.deleteRecord(zoneID: zone.id, recordID: id) }
                                }
                            }
                        }
                    }
                }
                .refreshable {
                    await viewModel.loadRecords(zoneID: zone.id)
                }
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
