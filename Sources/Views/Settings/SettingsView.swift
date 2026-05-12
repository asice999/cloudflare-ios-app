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
                Text("当前版本优先使用真实 Cloudflare 数据，并针对 iPhone 窄屏重新做了更保守的单列布局。")
                Text("建议使用最小权限 Token：Zone: Read、DNS: Read、DNS: Edit。")
            }
        }
        .navigationTitle("设置")
    }
}
