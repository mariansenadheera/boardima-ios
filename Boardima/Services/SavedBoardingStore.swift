import CoreData

@MainActor
final class SavedBoardingStore {
    private let context: NSManagedObjectContext
    private let entityName = "SavedBoarding"

    init(context: NSManagedObjectContext? = nil) {
        self.context = context ?? PersistenceController.shared.container.viewContext
    }

    func fetchIDs() -> Set<String> {
        let request = NSFetchRequest<NSManagedObject>(entityName: entityName)
        let results = (try? context.fetch(request)) ?? []
        return Set(results.compactMap { $0.value(forKey: "id") as? String })
    }

    func save(_ boarding: Boarding) {
        let object = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context)
        object.setValue(boarding.id, forKey: "id")
        object.setValue(boarding.title, forKey: "title")
        object.setValue(Date(), forKey: "savedAt")
        try? context.save()
    }

    func remove(id: String) {
        let request = NSFetchRequest<NSManagedObject>(entityName: entityName)
        request.predicate = NSPredicate(format: "id == %@", id)
        let results = (try? context.fetch(request)) ?? []
        results.forEach(context.delete)
        try? context.save()
    }
}
