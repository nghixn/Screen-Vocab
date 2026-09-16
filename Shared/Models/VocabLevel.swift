import Foundation

/// The CEFR levels actually present in wordbank.json. Descriptions follow
/// the "I can..." style of the official CEFR self-assessment grid, since
/// most learners can't reliably self-rate from a bare "A2/B1/B2" label.
enum VocabLevel: String, Codable, CaseIterable, Identifiable {
    case a2 = "A2"
    case b1 = "B1"
    case b2 = "B2"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .a2: return "A2 — Sơ cấp"
        case .b1: return "B1 — Trung cấp"
        case .b2: return "B2 — Trung cao cấp"
        }
    }

    var selfAssessment: String {
        switch self {
        case .a2:
            return "Tôi có thể giao tiếp đơn giản về những chủ đề quen thuộc hằng ngày (gia đình, mua sắm, nơi ở) và hiểu các câu, cụm từ thường dùng liên quan đến nhu cầu cơ bản."
        case .b1:
            return "Tôi có thể tự xử lý hầu hết tình huống khi đi du lịch, kể lại trải nghiệm, mô tả ước mơ/hy vọng, và trình bày ngắn gọn lý do cho ý kiến của mình."
        case .b2:
            return "Tôi có thể trao đổi khá trôi chảy và tự nhiên với người bản xứ, hiểu ý chính của các văn bản phức tạp, và trình bày quan điểm rõ ràng về nhiều chủ đề khác nhau."
        }
    }
}
