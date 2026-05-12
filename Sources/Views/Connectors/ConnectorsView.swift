import SwiftUI

struct ConnectorsView: View {
    private let items: [ConnectorItem] = [
        .init(name: "Cloudflare Tunnel", detail: "管理隧道与入口点", status: "待接入"),
        .init(name: "Zero Trust Connector", detail: "查看连接状态与设备接入", status: "待接入"),
        .init(name: "Origin Connector", detail: "管理源站接入配置", status: "待接入")
    ]

    var body: some View {
        List(items) { item in
            NavigationLink(destination: ConnectorDetailView(item: item)) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(item.name)
                            .font(.headline)
                        Spacer()
                        Text(item.status)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.orange.opacity(0.14))
                            .clipShape(Capsule())
                    }
                    Text(item.detail)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("连接器")
    }
}

private struct ConnectorItem: Identifiable {
    let id = UUID()
    let name: String
    let detail: String
    let status: String
}

private struct ConnectorDetailView: View {
    let item: ConnectorItem

    var body: some View {
        Form {
            Section("状态") {
                LabeledContent("名称", value: item.name)
                LabeledContent("状态", value: item.status)
                Text(item.detail)
                    .foregroundStyle(.secondary)
            }
            Section("下一步") {
                Text("这个模块已接入导航，后续会继续对接 Cloudflare Tunnel / Zero Trust 相关 API。")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle(item.name)
    }
}
