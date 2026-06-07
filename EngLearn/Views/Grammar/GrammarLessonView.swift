import SwiftUI

struct GrammarLessonView: View {
    let lesson: Lesson
    
    var body: some View {
        Text("Pelajaran: \(lesson.title)")
    }
}
