# CloudflareDNS

一个基于 **SwiftUI + Cloudflare API** 的 iOS 客户端 MVP。

## 当前功能
- API Token 登录与本地 Keychain 保存
- Zone 列表
- DNS 记录列表
- DNS 新增 / 编辑 / 删除

## 技术栈
- SwiftUI
- MVVM
- URLSession
- Keychain
- XcodeGen（用于生成 .xcodeproj）

## 本地运行
1. 安装 XcodeGen
2. 在仓库根目录执行：
   ```bash
   xcodegen generate
   ```
3. 打开 `CloudflareDNS.xcodeproj`
4. 选择签名团队（如果你要本地签名调试）
5. 运行

## Cloudflare Token 最小权限建议
- Zone: Read
- DNS: Read
- DNS: Edit

## GitHub Actions 输出
工作流会：
- 自动生成 Xcode 工程
- 构建未签名 iOS `.app`
- 打包为 `unsigned-CloudflareDNS.ipa`

> 注意：这是未签名 IPA，仅用于你后续自签处理，不可直接安装。
