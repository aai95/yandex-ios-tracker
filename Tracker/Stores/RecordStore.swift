import UIKit
import CoreData

enum RecordStoreError: Error {
    case convertTrackerIDError
    case convertCompletionDateError
}

struct RecordStoreChange {
    
    struct Move: Hashable {
        let oldIndex: Int
        let newIndex: Int
    }
    
    let indexesToInsert: IndexSet
    let indexesToDelete: IndexSet
    let indexesToReload: IndexSet
    let indexesToMove: Set<Move>
}

protocol RecordStoreDelegate: AnyObject {
    func storeDid(change: RecordStoreChange)
}

final class RecordStore: NSObject {
    
    private let context: NSManagedObjectContext
    
    private var resultsController: NSFetchedResultsController<RecordEntity>!
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    private var movedIndexes: Set<RecordStoreChange.Move>?
    
    weak var delegate: RecordStoreDelegate?
    
    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()
        
        let request = RecordEntity.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \RecordEntity.objectID, ascending: true)
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
    
    var fetchedRecords: Array<RecordModel> {
        guard let entities = resultsController.fetchedObjects,
              let models = try? entities.map({ try convert(entity: $0) })
        else {
            return []
        }
        return models
    }
    
    private func convert(entity: RecordEntity) throws -> RecordModel {
        guard let trackerID = entity.trackerID else {
            throw RecordStoreError.convertTrackerIDError
        }
        guard let completionDate = entity.completionDate else {
            throw RecordStoreError.convertCompletionDateError
        }
        return RecordModel(
            trackerID: trackerID,
            completionDate: completionDate
        )
    }
}

extension RecordStore: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
        updatedIndexes = IndexSet()
        movedIndexes = Set<RecordStoreChange.Move>()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.storeDid(
            change: RecordStoreChange(
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
                RecordStoreChange.Move(
                    oldIndex: oldPath.item,
                    newIndex: newPath.item
                )
            )
        @unknown default:
            fatalError("NSFetchedResultsChangeType has unknown default value")
        }
    }
}
