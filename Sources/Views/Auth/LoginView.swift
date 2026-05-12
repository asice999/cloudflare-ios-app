import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var appState: AppState
    @State private var token: String = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Cloudflare API Token") {
                    SecureField("请输入 Token", text: $token)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }

                Section {
                    Button {
                        Task { await submit() }
                    } label: {
                        if isLoading {
                            ProgressView()
                        } else {
                            Text("保存并登录")
                        }
                    }
                    .disabled(token.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
                }

                Section("建议权限") {
                    Text("Zone: Read")
                    Text("DNS: Read")
                    Text("DNS: Edit")
                }
            }
            .navigationTitle("连接 Cloudflare")
            .alert("登录失败", isPresented: .constant(errorMessage != nil), actions: {
                Button("确定") { errorMessage = nil }
            }, message: {
                Text(errorMessage ?? "")
            })
        }
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
