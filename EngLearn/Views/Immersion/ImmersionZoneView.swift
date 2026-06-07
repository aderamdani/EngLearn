import SwiftUI

struct ImmersionZoneView: View {
    @State private var idioms = [
        Idiom(phrase: "Piece of cake", meaning_id: "Sangat mudah", example: "The exam was a piece of cake.", context_id: "Digunakan saat sesuatu sangat mudah dilakukan."),
        Idiom(phrase: "Break a leg", meaning_id: "Semoga berhasil", example: "Break a leg at your performance tonight!", context_id: "Ungkapan populer untuk menyemangati seseorang di panggung."),
        Idiom(phrase: "Under the weather", meaning_id: "Merasa kurang enak badan", example: "I'm feeling a bit under the weather today.", context_id: "Digunakan saat kamu sakit ringan seperti flu."),
        Idiom(phrase: "Once in a blue moon", meaning_id: "Sangat jarang terjadi", example: "He visits his home once in a blue moon.", context_id: "Untuk aksi yang frekuensinya sangat rendah."),
        Idiom(phrase: "The best of both worlds", meaning_id: "Mendapatkan keuntungan dari dua situasi berbeda", example: "She has the best of both worlds with her job and family.", context_id: "Situasi ideal di mana kamu untung dua kali lipat.")
    ]
    
    struct Idiom: Identifiable {
        let id = UUID()
        let phrase: String
        let meaning_id: String
        let example: String
        let context_id: String
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: Spacing.lg) {
                    ForEach(idioms) { idiom in
                        idiomCard(idiom)
                    }
                }
                .padding(Spacing.lg)
            }
            .navigationTitle("Immersion Zone")
            .background(.regularMaterial)
        }
    }
    
    private func idiomCard(_ idiom: Idiom) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text(idiom.phrase)
                .font(.title2.bold())
                .foregroundColor(.accentColor)
            
            Text(idiom.meaning_id)
                .font(.headline)
            
            Divider()
            
            Text("Contoh:").font(.caption.bold())
            Text(idiom.example).font(.body.italic())
            
            Text("Tips:").font(.caption.bold()).padding(.top, Spacing.xs)
            Text(idiom.context_id).font(.caption).foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background, in: RoundedRectangle(cornerRadius: CornerRadius.card))
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: CornerRadius.card))
        .accessibilityLabel("Idiom: \(idiom.phrase), arti: \(idiom.meaning_id)")
    }
}

#Preview {
    ImmersionZoneView()
}
