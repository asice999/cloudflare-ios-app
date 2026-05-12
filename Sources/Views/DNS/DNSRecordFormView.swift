import SwiftUI

struct DNSRecordFormView: View {
    let zone: Zone
    let existingRecord: DNSRecord?

    @Environment(\.dismiss) private var dismiss

    @State private var type: String = "A"
    @State private var name: String = ""
    @State private var content: String = ""
    @State private var ttl: String = "1"
    @State private var proxied: Bool = false
    @State private var isSaving = false
    @State private var errorMessage: String?

    private let api = CloudflareAPIClient()
    private let supportedTypes = ["A", "AAAA", "CNAME", "TXT"]

    init(zone: Zone, existingRecord: DNSRecord?) {
        self.zone = zone
        self.existingRecord = existingRecord
        _type = State(initialValue: existingRecord?.type ?? "A")
        _name = State(initialValue: existingRecord?.name ?? "")
        _content = State(initialValue: existingRecord?.content ?? "")
        _ttl = State(initialValue: String(existingRecord?.ttl ?? 1))
        _proxied = State(initialValue: existingRecord?.proxied ?? false)
    }

    var body: some View {
        Form {
            Section("基础信息") {
                Picker("类型", selection: $type) {
                    ForEach(supportedTypes, id: \.self) { item in
                        Text(item).tag(item)
                    }
                }

                TextField("名称", text: $name)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                TextField("内容", text: $content)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                TextField("TTL", text: $ttl)
                    .keyboardType(.numberPad)

                Toggle("开启代理", isOn: $proxied)
            }

            Section {
                Button {
                    Task { await save() }
                } label: {
                    if isSaving {
                        ProgressView()
                    } else {
                        Text(existingRecord == nil ? "创建记录" : "保存修改")
                    }
                }
                .disabled(isSaving || name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .navigationTitle(existingRecord == nil ? "新建 DNS" : "编辑 DNS")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("关闭") { dismiss() }
            }
        }
        .alert("保存失败", isPresented: .constant(errorMessage != nil), actions: {
            Button("确定") { errorMessage = nil }
        }, message: {
            Text(errorMessage ?? "")
        })
    }

    private func save() async {
        isSaving = true
        defer { isSaving = false }

        guard let ttlValue = Int(ttl) else {
            errorMessage = "TTL 必须是数字"
            return
        }

        let payload = DNSRecordRequest(
            type: type,
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            content: content.trimmingCharacters(in: .whitespacesAndNewlines),
            ttl: ttlValue,
            proxied: type == "TXT" ? nil : proxied
        )

        do {
            if let recordID = existingRecord?.id {
                try await api.updateDNSRecord(zoneID: zone.id, recordID: recordID, payload: payload)
            } else {
                try await api.createDNSRecord(zoneID: zone.id, payload: payload)
            }
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
