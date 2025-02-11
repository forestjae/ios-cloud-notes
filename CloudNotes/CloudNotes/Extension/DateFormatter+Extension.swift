import Foundation

extension DateFormatter {
    static let memoDate: DateFormatter = {
        let formatter = DateFormatter()
        let locale = Locale.preferredLanguages.first ?? Locale.current.identifier
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: locale)

        return formatter
    }()
}
