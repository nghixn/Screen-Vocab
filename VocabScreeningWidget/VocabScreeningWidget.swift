import WidgetKit
import SwiftUI

struct VocabScreeningWidget: Widget {
    let kind = "VocabScreeningWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            VocabWidgetView(entry: entry)
        }
        .configurationDisplayName("Vocab Screening")
        .description("Từ vựng mới mỗi giờ, ngay trên màn hình khoá.")
        .supportedFamilies([
            .accessoryRectangular,
            .accessoryInline,
            .systemMedium
        ])
    }
}
