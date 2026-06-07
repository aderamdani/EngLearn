import OSLog

enum Log {
    static let general = Logger(
        subsystem: AppConstants.logSubsystem,
        category: "general"
    )
    static let lessons = Logger(
        subsystem: AppConstants.logSubsystem,
        category: "lessons"
    )
    static let srs = Logger(
        subsystem: AppConstants.logSubsystem,
        category: "spaced-repetition"
    )
    static let speech = Logger(
        subsystem: AppConstants.logSubsystem,
        category: "speech"
    )
    static let audio = Logger(
        subsystem: AppConstants.logSubsystem,
        category: "audio"
    )
    static let data = Logger(
        subsystem: AppConstants.logSubsystem,
        category: "data"
    )
    static let ui = Logger(
        subsystem: AppConstants.logSubsystem,
        category: "ui"
    )
    static let performance = Logger(
        subsystem: AppConstants.logSubsystem,
        category: "performance"
    )
}
