import CoreData

class PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "Transcription") // Use the name of your data model file
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                // Handle the error, e.g., fatalError("Unresolved error \(error), \(error.userInfo)")
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
}

