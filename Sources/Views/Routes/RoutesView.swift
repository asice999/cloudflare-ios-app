import SwiftUI

struct RoutesView: View {
    private let items: [RouteItem] = [
        .init(title: "Workers Routes", description: "把域名路径映射到 Workers", kind: "Workers"),
        .init(title: "Tunnel Routes", description: "查看 Tunnel 出入口与域名绑定", kind: "Tunnel"),
        .init(title: "Network Routes", description: "后续扩展到更通用的网络路由管理", kind: "Network")
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                ForEach(items) { item in
                    NavigationLink(destination: RouteDetailView(item: item)) {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text(item.title)
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                Spacer()
                                Text(item.kind)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.12))
                                    .clipShape(Capsule())
                            }
                            Text(item.description)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(18)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .contentShape(RoundedRectangle(cornerRadius: 18))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("路由")
    }
}

private struct RouteItem: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let kind: String
}

private struct RouteDetailView: View {
    let item: RouteItem

    var body: some View {
        Form {
            Section("路由类型") {
                LabeledContent("名称", value: item.title)
                LabeledContent("类型", value: item.kind)
                Text(item.description)
                    .foregroundStyle(.secondary)
            }
            Section("下一步") {
                Text("这个模块已接入导航，后续会继续对接 Workers Routes / Tunnel Routes 等接口。")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle(item.title)
    }
}
