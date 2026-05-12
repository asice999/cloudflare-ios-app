import SwiftUI

struct SubscriptionView: View {
    @State private var selectedPlan: SubscriptionPlan = .lifetime

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                RoundedRectangle(cornerRadius: 28)
                    .fill(LinearGradient(colors: [.orange.opacity(0.95), .orange], startPoint: .leading, endPoint: .trailing))
                    .frame(height: 120)
                    .overlay {
                        Text("完美管理您的网站")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .shadow(color: .orange.opacity(0.25), radius: 14, y: 8)

                featureRow(icon: "calendar.badge.plus", text: "更改分析的日期范围")
                featureRow(icon: "chart.bar.xaxis", text: "更多详细信息关于流量来源")
                featureRow(icon: "ticket", text: "在应用内启用遭受攻击模式和开发模式")
                featureRow(icon: "speedometer", text: "自定义数据刷新速率")
                featureRow(icon: "tv", text: "去除广告，享受无打扰体验")
                featureRow(icon: "arrow.triangle.2.circlepath", text: "您可以随时取消订阅")

                HStack(spacing: 12) {
                    planCard(.monthly, title: "包月", price: "¥28.00")
                    planCard(.yearly, title: "包年", price: "¥298.00", badge: "-11%")
                    planCard(.lifetime, title: "终身", price: "¥698.00", badge: "∞")
                }

                Button {
                } label: {
                    HStack {
                        Spacer()
                        Text("开始")
                            .font(.title3.bold())
                        Image(systemName: "chevron.right")
                        Spacer()
                    }
                    .foregroundStyle(.white)
                    .padding(.vertical, 18)
                    .background(LinearGradient(colors: [.orange.opacity(0.95), .orange], startPoint: .leading, endPoint: .trailing))
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                    .shadow(color: .orange.opacity(0.22), radius: 10, y: 5)
                }

                Button("以后再说") {
                }
                .font(.title3)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.white)
                .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.orange.opacity(0.25), lineWidth: 1.5))
                .clipShape(RoundedRectangle(cornerRadius: 22))

                HStack {
                    Spacer()
                    Text("恢复")
                    Spacer()
                    Text("条款")
                    Spacer()
                    Text("隐私")
                    Spacer()
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
            .padding(20)
        }
        .background(
            LinearGradient(colors: [Color.orange.opacity(0.12), Color.white], startPoint: .top, endPoint: .center)
                .ignoresSafeArea()
        )
        .navigationTitle("订阅")
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 18) {
            Circle()
                .stroke(Color.orange.opacity(0.25), lineWidth: 1)
                .frame(width: 58, height: 58)
                .overlay(Image(systemName: icon).foregroundStyle(.orange).font(.title3))
            Text(text)
                .font(.title3)
            Spacer()
        }
    }

    private func planCard(_ plan: SubscriptionPlan, title: String, price: String, badge: String? = nil) -> some View {
        VStack(spacing: 8) {
            if let badge {
                Text(badge)
                    .font(.caption.bold())
                    .foregroundStyle(plan == selectedPlan ? .white : .orange)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(plan == selectedPlan ? Color.orange : Color.orange.opacity(0.10))
                    .clipShape(Capsule())
            } else {
                Spacer().frame(height: 24)
            }

            Text(title)
                .font(.title3.bold())
            Text(price)
                .font(.title3)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 140)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(plan == selectedPlan ? Color.orange : Color.gray.opacity(0.20), lineWidth: plan == selectedPlan ? 2.5 : 1.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .onTapGesture {
            selectedPlan = plan
        }
    }
}

enum SubscriptionPlan {
    case monthly
    case yearly
    case lifetime
}
