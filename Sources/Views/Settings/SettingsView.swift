import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        Form {
            Section("账户") {
                Button("退出登录", role: .destructive) {
                    appState.logout()
                }
            }

            Section("说明") {
                Text("这是第一版 MVP，当前仅支持 Cloudflare Token 登录、Zone 列表和 DNS 管理。")
                Text("建议使用最小权限 Token：Zone: Read、DNS: Read、DNS: Edit。")
            }
        }
        .navigationTitle("设置")
    }
}
