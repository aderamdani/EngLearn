import Foundation

enum AppError: LocalizedError {
    case lessonNotFound(id: String)
    case jsonDecodingFailed(file: String, underlying: Error)
    case audioPlaybackFailed(underlying: Error)
    case speechRecognitionDenied
    case speechRecognitionFailed(underlying: Error)
    case microphoneAccessDenied
    case dataCorrupted(model: String)
    case migrationFailed(from: Int, to: Int)
    case exportFailed(format: String, underlying: Error)
    case invalidExerciseData(id: String)

    var errorDescription: String? {
        switch self {
        case .lessonNotFound(let id):
            return "Pelajaran '\(id)' tidak ditemukan."
        case .jsonDecodingFailed(let file, _):
            return "Gagal memuat data kurikulum dari '\(file)'."
        case .audioPlaybackFailed:
            return "Gagal memutar audio."
        case .speechRecognitionDenied:
            return "Akses pengenalan suara ditolak."
        case .speechRecognitionFailed:
            return "Pengenalan suara gagal. Coba lagi."
        case .microphoneAccessDenied:
            return "Akses mikrofon ditolak."
        case .dataCorrupted(let model):
            return "Data '\(model)' rusak."
        case .migrationFailed(let from, let to):
            return "Migrasi data gagal (v\(from) ke v\(to))."
        case .exportFailed(let format, _):
            return "Gagal mengekspor ke format \(format)."
        case .invalidExerciseData(let id):
            return "Data latihan '\(id)' tidak valid."
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .microphoneAccessDenied:
            return "Buka Pengaturan Sistem > Privasi & Keamanan > Mikrofon, lalu aktifkan untuk EngLearn."
        case .speechRecognitionDenied:
            return "Buka Pengaturan Sistem > Privasi & Keamanan > Pengenalan Suara, lalu aktifkan untuk EngLearn."
        case .audioPlaybackFailed:
            return "Pastikan volume tidak di-mute dan coba lagi."
        case .jsonDecodingFailed, .invalidExerciseData:
            return "Coba tutup dan buka ulang aplikasi. Jika masih bermasalah, instal ulang EngLearn."
        case .dataCorrupted, .migrationFailed:
            return "Data kamu mungkin perlu di-reset. Buka Pengaturan > Reset Progress."
        case .exportFailed:
            return "Pastikan kamu punya akses tulis ke folder tujuan, lalu coba lagi."
        case .lessonNotFound:
            return "Pelajaran ini mungkin belum tersedia untuk level kamu."
        case .speechRecognitionFailed:
            return "Pastikan mikrofon berfungsi dan coba bicara lebih jelas."
        }
    }
}
