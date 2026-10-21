import CoreData

final class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Boardima", managedObjectModel: Self.makeModel())
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { _, error in
            if let error {
                assertionFailure("Core Data failed to load: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    }

    private static func makeModel() -> NSManagedObjectModel {
        let entity = NSEntityDescription()
        entity.name = "SavedBoarding"

        func attribute(_ name: String, _ type: NSAttributeType) -> NSAttributeDescription {
            let attribute = NSAttributeDescription()
            attribute.name = name
            attribute.attributeType = type
            attribute.isOptional = false
            return attribute
        }

        entity.properties = [
            attribute("id", .stringAttributeType),
            attribute("title", .stringAttributeType),
            attribute("savedAt", .dateAttributeType)
        ]
        entity.uniquenessConstraints = [["id"]]

        let model = NSManagedObjectModel()
        model.entities = [entity]
        return model
    }
}
