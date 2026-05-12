import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var appState: AppState
    @State private var token: String = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @FocusState private var tokenFocused: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    heroSection
                    tokenCard
                    permissionCard
                    tipsCard
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("连接 Cloudflare")
            .navigationBarTitleDisplayMode(.inline)
            .alert("登录失败", isPresented: .constant(errorMessage != nil), actions: {
                Button("确定") { errorMessage = nil }
            }, message: {
                Text(errorMessage ?? "")
            })
        }
    }

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: "cloud.fill")
                .font(.system(size: 34))
                .foregroundStyle(.white)
                .frame(width: 60, height: 60)
                .background(
                    LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .clipShape(RoundedRectangle(cornerRadius: 18))

            Text("随时管理你的 Cloudflare")
                .font(.title2.bold())
            Text("输入 API Token 后即可查看域名、DNS、分析和网络配置。")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var tokenCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Cloudflare API Token", systemImage: "key.horizontal.fill")
                .font(.headline)

            SecureField("请输入 Token", text: $token)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .focused($tokenFocused)
                .padding(14)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))

            Button {
                Task { await submit() }
            } label: {
                HStack {
                    Spacer()
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("保存并登录")
                            .fontWeight(.semibold)
                    }
                    Spacer()
                }
                .padding(.vertical, 14)
                .foregroundStyle(.white)
                .background(token.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading ? Color.gray : Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(token.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
        }
        .padding(18)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var permissionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("建议最小权限", systemImage: "lock.shield.fill")
                .font(.headline)
            PermissionRow(title: "Zone", value: "Read")
            PermissionRow(title: "DNS", value: "Read")
            PermissionRow(title: "DNS", value: "Edit")
        }
        .padding(18)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var tipsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("使用说明", systemImage: "sparkles")
                .font(.headline)
            Text("建议为本 App 单独创建一个受限 Token，不要使用 Global API Key。")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("第一版已支持 DNS 管理，并预留了数据分析、连接器和路由模块。")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(18)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func submit() async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await appState.login(token: token.trimmingCharacters(in: .whitespacesAndNewlines))
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

private struct PermissionRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
        .font(.subheadline)
    }
}
