import SwiftUI
import UIKit

struct SettingsView: View {
    @AppStorage("reminderEnabled") private var reminderEnabled = false
    @AppStorage("reminderHour") private var reminderHour = 20
    @AppStorage("reminderMinute") private var reminderMinute = 0
    @State private var showPermissionDeniedAlert = false

    private var reminderTime: Binding<Date> {
        Binding(
            get: {
                Calendar.current.date(bySettingHour: reminderHour, minute: reminderMinute, second: 0, of: Date()) ?? Date()
            },
            set: { newDate in
                let comps = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                reminderHour = comps.hour ?? 20
                reminderMinute = comps.minute ?? 0
                if reminderEnabled {
                    NotificationScheduler.shared.scheduleDailyReminder(hour: reminderHour, minute: reminderMinute)
                }
            }
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Bật thông báo nhắc học", isOn: $reminderEnabled)
                        .onChange(of: reminderEnabled) { enabled in
                            if enabled {
                                NotificationScheduler.shared.requestAuthorization { granted in
                                    if granted {
                                        NotificationScheduler.shared.scheduleDailyReminder(hour: reminderHour, minute: reminderMinute)
                                    } else {
                                        reminderEnabled = false
                                        showPermissionDeniedAlert = true
                                    }
                                }
                            } else {
                                NotificationScheduler.shared.cancelDailyReminder()
                            }
                        }

                    if reminderEnabled {
                        DatePicker("Giờ nhắc", selection: reminderTime, displayedComponents: .hourAndMinute)
                    }
                } header: {
                    Text("Nhắc học hằng ngày")
                } footer: {
                    Text("Ứng dụng sẽ gửi một thông báo vào đúng giờ này mỗi ngày để nhắc bạn quay lại ôn từ vựng.")
                }
            }
            .navigationTitle("Cài đặt")
            .onAppear(perform: syncWithSystemPermission)
            .alert("Chưa cấp quyền thông báo", isPresented: $showPermissionDeniedAlert) {
                Button("Mở Cài đặt") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Đóng", role: .cancel) {}
            } message: {
                Text("Vui lòng bật quyền thông báo trong Cài đặt hệ thống để nhận nhắc nhở học hằng ngày.")
            }
        }
    }

    /// If the user revoked notification permission from the system Settings
    /// app directly, reflect that here instead of showing a toggle that lies.
    private func syncWithSystemPermission() {
        guard reminderEnabled else { return }
        NotificationScheduler.shared.checkAuthorizationStatus { status in
            if status == .denied {
                reminderEnabled = false
                NotificationScheduler.shared.cancelDailyReminder()
            }
        }
    }
}
