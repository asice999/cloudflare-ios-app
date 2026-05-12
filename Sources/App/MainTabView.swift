import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                OverviewView()
            }
            .tabItem {
                Label("概览", systemImage: "square.grid.2x2.fill")
            }

            NavigationStack {
                ZoneListView()
            }
            .tabItem {
                Label("域名", systemImage: "globe")
            }

            NavigationStack {
                AnalyticsView()
            }
            .tabItem {
                Label("分析", systemImage: "chart.xyaxis.line")
            }

            NavigationStack {
                ConnectorsView()
            }
            .tabItem {
                Label("连接器", systemImage: "link.badge.plus")
            }

            NavigationStack {
                RoutesView()
            }
            .tabItem {
                Label("路由", systemImage: "point.3.connected.trianglepath.dotted")
            }

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("设置", systemImage: "gearshape")
            }
        }
    }
}
