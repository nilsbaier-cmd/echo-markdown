import Foundation
import CoreData

final class CoreDataService: CoreDataServiceProtocol {
    static let shared = CoreDataService()

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "EchoDataModel")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Core Data failed to load: \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()

    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    func saveContext() throws {
        let context = viewContext
        if context.hasChanges {
            try context.save()
        }
    }

    func newBackgroundContext() -> NSManagedObjectContext {
        persistentContainer.newBackgroundContext()
    }
}
