import SwiftUI
import CoreData

struct TranscriptionHistoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Transcription.date, ascending: false)],
        animation: .default)
    private var transcriptions: FetchedResults<Transcription>
    @State private var searchQuery = ""

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.6), Color.blue.opacity(0.6)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)

            VStack {
                // Search bar
                TextField("Search", text: $searchQuery)
                    .padding(10)
                    .background(Color.white.opacity(0.5))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .foregroundColor(.black)
                    .onChange(of: searchQuery) { newValue in
                        // Update the fetch request based on the search query
                        transcriptions.nsPredicate = searchQuery.isEmpty ? nil : NSPredicate(format: "(conversation CONTAINS[c] %@) OR (transcript CONTAINS[c] %@)", searchQuery, searchQuery)
                    }

                // Transcriptions list
                List {
                    ForEach(filteredTranscriptions, id: \.self) { transcription in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(transcription.conversation ?? "Unknown")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("\(transcription.date ?? Date(), formatter: dateFormatter)")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                            Text(transcription.transcript ?? "No Transcript")
                                .font(.body)
                                .foregroundColor(.white)
                        }
                        .listRowBackground(Color.black.opacity(0.3))
                    }
                    .onDelete(perform: deleteItems)
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationTitle("Transcription History")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var filteredTranscriptions: [Transcription] {
        if searchQuery.isEmpty {
            return Array(transcriptions)
        } else {
            return transcriptions.filter { transcription in
                transcription.conversation?.lowercased().contains(searchQuery.lowercased()) ?? false ||
                transcription.transcript?.lowercased().contains(searchQuery.lowercased()) ?? false
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { filteredTranscriptions[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Handle the Core Data error, e.g., show an alert.
            }
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    formatter.timeStyle = .medium
    return formatter
}()
