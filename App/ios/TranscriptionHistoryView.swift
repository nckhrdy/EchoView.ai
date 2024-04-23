import SwiftUI
import CoreData

struct AnimatedGradBackground: View {
    @State private var isAnimating = false

    let gradientColors = [Gradient(colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.3), Color.purple.opacity(0.3
                                                                                                                    )])]
    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()

    var body: some View {
        LinearGradient(gradient: gradientColors[0], startPoint: isAnimating ? .topLeading : .bottomTrailing, endPoint: isAnimating ? .bottomTrailing : .topLeading)
            .animation(Animation.easeInOut(duration: 5).repeatForever(autoreverses: false), value: isAnimating)
            .onReceive(timer) { _ in
                isAnimating.toggle()
            }
            .edgesIgnoringSafeArea(.all)
    }
}

struct TranscriptionHistoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Transcription.date, ascending: false)],
        animation: .default)
    private var transcriptions: FetchedResults<Transcription>
    @State private var searchQuery = ""

    var body: some View {
        ZStack {
            //Background Color
//            Color.white.edgesIgnoringSafeArea(.all) // Set background to white for a sleek look
            AnimatedGradBackground()
            
            VStack {
                // Search bar
                TextField("Search", text: $searchQuery)
                    .font(.custom("Jersey 10", size: 20))
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
                                .foregroundColor(.purple.opacity(0.7))
                            Text(transcription.transcript ?? "No Transcript")
                                .font(.body)
                                .foregroundColor(.black)
                        }
                        .listRowBackground(Color.gray.opacity(0.3))
                    }
                    .onDelete(perform: deleteItems)
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationBarTitle("", displayMode: .inline)
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
