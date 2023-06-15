import UIKit
import CoreData

enum TrackerStoreError: Error {
    case convertIDError
    case convertNameError
    case convertHexColorError
    case convertEmojiError
}

struct TrackerStoreChange {
    
    struct Move: Hashable {
        let oldIndex: Int
        let newIndex: Int
    }
    
    let indexesToInsert: IndexSet
    let indexesToDelete: IndexSet
    let indexesToReload: IndexSet
    let indexesToMove: Set<Move>
}

protocol TrackerStoreDelegate: AnyObject {
    func storeDid(change: TrackerStoreChange)
}

final class TrackerStore: NSObject {
    
    private let colorSerializer = UIColorSerializer()
    private let scheduleSerializer = ScheduleSerializer()
    private let context: NSManagedObjectContext
    
    private var resultsController: NSFetchedResultsController<TrackerEntity>!
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    private var movedIndexes: Set<TrackerStoreChange.Move>?
    
    weak var delegate: TrackerStoreDelegate?
    
    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()
        
        let request = TrackerEntity.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerEntity.objectID, ascending: true)
        ]
        let controller = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        
        resultsController = controller
        try resultsController.performFetch()
    }
    
    convenience override init() {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            preconditionFailure("Failed to cast UIApplicationDelegate as AppDelegate")
        }
        try! self.init(context: delegate.persistentContainer.viewContext)
    }
    
    var fetchedTrackers: Array<TrackerModel> {
        guard let entities = resultsController.fetchedObjects,
              let models = try? entities.map({ try convert(entity: $0) })
        else {
            return []
        }
        return models
    }
    
    func addTracker(model: TrackerModel, to category: String) throws {
        try updateTracker(entity: TrackerEntity(context: context), using: model, in: category)
        try context.save()
    }
    
    func updateTracker(entity: TrackerEntity, using model: TrackerModel, in title: String) throws {
        entity.id = model.id
        entity.name = model.name
        entity.hexColor = colorSerializer.serialize(color: model.color)
        entity.emoji = model.emoji
        entity.weekDays = scheduleSerializer.serialize(schedule: model.schedule)
        entity.category = try fetchCategory(by: title)
        entity.records = NSSet()
    }
    
    func convert(entity: TrackerEntity) throws -> TrackerModel {
        guard let id = entity.id else {
            throw TrackerStoreError.convertIDError
        }
        guard let name = entity.name else {
            throw TrackerStoreError.convertNameError
        }
        guard let hexColor = entity.hexColor else {
            throw TrackerStoreError.convertHexColorError
        }
        guard let emoji = entity.emoji else {
            throw TrackerStoreError.convertEmojiError
        }
        return TrackerModel(
            id: id,
            name: name,
            color: colorSerializer.deserialize(hex: hexColor),
            emoji: emoji,
            schedule: scheduleSerializer.deserialize(days: entity.weekDays)
        )
    }
    
    private func fetchCategory(by title: String) throws -> CategoryEntity {
        let request = NSFetchRequest<CategoryEntity>(entityName: "CategoryEntity")
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(CategoryEntity.title), title)
        return try context.fetch(request)[0]
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
        updatedIndexes = IndexSet()
        movedIndexes = Set<TrackerStoreChange.Move>()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.storeDid(
            change: TrackerStoreChange(
                indexesToInsert: insertedIndexes!,
                indexesToDelete: deletedIndexes!,
                indexesToReload: updatedIndexes!,
                indexesToMove: movedIndexes!
            )
        )
        insertedIndexes = nil
        deletedIndexes = nil
        updatedIndexes = nil
        movedIndexes = nil
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        switch type {
        case .insert:
            guard let path = newIndexPath else {
                preconditionFailure("Failed to unwrap newIndexPath")
            }
            insertedIndexes?.insert(path.item)
        case .delete:
            guard let path = indexPath else {
                preconditionFailure("Failed to unwrap indexPath")
            }
            deletedIndexes?.insert(path.item)
        case .update:
            guard let path = indexPath else {
                preconditionFailure("Failed to unwrap indexPath")
            }
            updatedIndexes?.insert(path.item)
        case .move:
            guard let oldPath = indexPath,
                  let newPath = newIndexPath
            else {
                preconditionFailure("Failed to unwrap indexPath or newIndexPath")
            }
            movedIndexes?.insert(
                TrackerStoreChange.Move(
                    oldIndex: oldPath.item,
                    newIndex: newPath.item
                )
            )
        @unknown default:
            fatalError("NSFetchedResultsChangeType has unknown default value")
        }
    }
}
