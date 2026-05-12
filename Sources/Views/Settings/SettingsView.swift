import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        List {
            NavigationLink(destination: SubscriptionView()) {
                Label("订阅与高级功能", systemImage: "crown.fill")
                    .foregroundStyle(.orange)
            }

            Section("账户") {
                Button("退出登录", role: .destructive) {
                    appState.logout()
                }
            }

            Section("说明") {
                Text("当前版本已接入新的概览仪表盘样式，并补充了分析、连接器、路由与订阅页面骨架。")
                Text("建议使用最小权限 Token：Zone: Read、DNS: Read、DNS: Edit。")
            }
        }
        .navigationTitle("设置")
    }
}
