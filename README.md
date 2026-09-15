# Vocab Screening

Ứng dụng iOS hiển thị một từ vựng tiếng Anh (B1-B2) mới mỗi giờ trên **Lock
Screen widget** và **Home Screen widget**, kèm cơ chế **spaced repetition
(Leitner)** và **active recall** (chạm để lật thẻ trước khi xem nghĩa) để
tăng hiệu quả ghi nhớ so với việc chỉ hiển thị thụ động.

## Kiến trúc

- **`Shared/`** — code + dữ liệu dùng chung giữa app chính và widget
  extension:
  - `Models/` — `Word`, `WordProgress` (trạng thái SRS của từng từ).
  - `Data/WordBank.swift` — nạp bộ từ vựng từ `Resources/wordbank.json`
    (447 từ A2-B2, tự biên soạn kèm nghĩa tiếng Việt, IPA, ví dụ — **không**
    sao chép danh sách có bản quyền như Oxford 3000/5000, để tránh vấn đề
    bản quyền. Phủ các chủ đề: cảm xúc/tính cách, công việc, du lịch, công
    nghệ, sức khoẻ, giáo dục, môi trường, quan hệ xã hội, tiền bạc, động từ
    học thuật, tính từ mô tả, từ nối, đời sống hàng ngày).
  - `SRS/SRSEngine.swift` — thuật toán Leitner 6 box (1h → 4h → 1 ngày →
    3 ngày → 1 tuần → 3 tuần), điều chỉnh theo phản hồi Đã nhớ/Chưa nhớ.
  - `Scheduling/ScheduleGenerator.swift` — tính sẵn **24 entry cho 24 giờ
    tới** (từ nào hiển thị vào giờ nào), ưu tiên từ đến hạn ôn tập, sau đó
    mới giới thiệu từ mới (tối đa 8 từ mới/ngày).
  - `Persistence/SharedStore.swift` — đọc/ghi tiến độ SRS và lịch từ vựng
    vào **App Group container**, để cả app và widget cùng đọc được.
- **`VocabScreening/`** — app chính (SwiftUI): flashcard active-recall
  (`FlashcardView`), màn hình thống kê (`StatsView`), và màn hình cài đặt
  (`SettingsView`). Có nút loa 🔊 để nghe phát âm từ và câu ví dụ, dùng
  `PronunciationPlayer.swift` (AVSpeechSynthesizer — giọng đọc tiếng Anh
  tổng hợp trên máy, không cần mạng, giọng en-GB khớp với IPA kiểu Anh-Anh
  đã ghi trong wordbank). `NotificationScheduler.swift` lên lịch **thông
  báo nhắc học lặp lại hằng ngày** (local notification, không cần server)
  vào giờ do người dùng chọn trong Cài đặt.
- **`VocabScreeningWidget/`** — widget extension (WidgetKit): 1 target
  cung cấp cả widget Lock Screen (`.accessoryRectangular`/`.accessoryInline`
  — chỉ đủ chỗ cho từ + phát âm) và widget Home Screen
  (`.systemMedium` — đủ chỗ cho cả nghĩa + ví dụ).

### Vì sao đổi từ đúng mỗi giờ dù iOS giới hạn refresh?

iOS không cho refresh widget tuỳ ý mỗi giờ (background budget). Thay vì phụ
thuộc vào refresh, `Provider.getTimeline` tính sẵn **nhiều `TimelineEntry`
cùng lúc**, mỗi entry có timestamp riêng — iOS tự chuyển sang entry đúng
giờ mà không cần đánh thức extension liên tục. App/widget chỉ cần chạy nền
~1 lần/ngày để sinh batch tiếp theo.

## Yêu cầu

- macOS + Xcode 15 trở lên
- [XcodeGen](https://github.com/yonaskolb/XcodeGen): `brew install xcodegen`

## Cách chạy

```bash
xcodegen generate          # tạo VocabScreening.xcodeproj từ project.yml
open VocabScreening.xcodeproj
```

Trong Xcode, với **cả 2 target** (`VocabScreening` và
`VocabScreeningWidgetExtension`):

1. Tab **Signing & Capabilities** → chọn Team (Apple ID cá nhân dùng được,
   không bắt buộc phải có Apple Developer Program để chạy trên thiết bị
   thật/simulator khi dev).
2. Nếu `com.nghixn.vocabscreening` bị trùng, đổi Bundle Identifier — nhớ
   đổi luôn App Group ID tương ứng ở 2 chỗ:
   - `project.yml` (`group.com.nghixn.vocabscreening`, xuất hiện 2 lần)
   - `Shared/Persistence/SharedStore.swift` (`appGroupId`)
   rồi chạy lại `xcodegen generate`.
3. Capability **App Groups** đã được khai báo sẵn qua entitlements trong
   `project.yml` — nếu Xcode báo thiếu, bật thủ công trong tab Signing &
   Capabilities rồi chọn đúng group ID ở trên.

Chạy app (Cmd+R) trên **thiết bị thật** (khuyến nghị hơn simulator để test
Lock Screen widget đúng thực tế) ít nhất 1 lần — lần mở đầu tiên sẽ sinh
lịch 24 giờ đầu tiên.

Sau đó, trên thiết bị:

- **Lock Screen widget**: nhấn giữ màn hình khoá → Tuỳ chỉnh → thêm widget
  "Vocab Screening" (dạng chữ nhật) vào Lock Screen.
- **Home Screen widget**: nhấn giữ Home Screen → thêm widget → chọn
  "Vocab Screening" (size Medium) để xem đủ nghĩa + ví dụ.

## Giới hạn hiện tại (MVP)

- Bộ từ vựng hiện có 447 từ (đủ dùng khoảng vài tháng ở nhịp giới thiệu tối đa
  8 từ mới/ngày) — có thể mở rộng thêm bất cứ lúc nào bằng cách thêm trực tiếp
  vào `Shared/Resources/wordbank.json` theo đúng format.
- Audio phát âm dùng **text-to-speech tổng hợp trên máy** (AVSpeechSynthesizer),
  không phải giọng người bản xứ thu âm sẵn. Đây là đánh đổi hợp lý cho MVP:
  hoạt động offline, phủ đủ cả 447 từ ngay lập tức, không tốn dung lượng app
  hay phụ thuộc API bên ngoài. Nếu muốn giọng người thật, có thể nâng cấp lên
  gọi dictionary API (vd. Free Dictionary API) để tải file audio thật và
  cache lại — nhưng sẽ cần mạng ở lần nghe đầu tiên và không phải từ nào cũng
  có sẵn audio.
- Widget (Lock Screen/Home Screen) **không tự phát âm được** — WidgetKit
  extension không có khả năng phát audio. Chạm vào widget sẽ mở app, và app
  luôn hiển thị đúng từ đang có trên widget để bấm nghe.
- Widget Lock Screen chưa hỗ trợ tương tác (bấm Đã nhớ/Chưa nhớ ngay trên
  đó) — thao tác Đã nhớ/Chưa nhớ hiện thực hiện trong app (`FlashcardView`).
- Thông báo nhắc học hằng ngày dùng nội dung tĩnh (chưa nhúng từ vựng cụ thể
  của ngày hôm đó) — đây là đánh đổi để lịch nhắc đáng tin cậy kể cả khi
  người dùng không mở app trong nhiều ngày. Nếu tắt quyền thông báo từ
  Cài đặt hệ thống, app sẽ tự tắt lại công tắc trong `SettingsView` ở lần
  mở tiếp theo.
- Chưa có streak (chuỗi ngày học liên tục).
