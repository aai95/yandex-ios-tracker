import UIKit
import CoreData

struct CategoryStoreChange {
    
    struct Move: Hashable {
        let oldIndex: Int
        let newIndex: Int
    }
    
    let indexesToInsert: IndexSet
    let indexesToDelete: IndexSet
    let indexesToReload: IndexSet
    let indexesToMove: Set<Move>
}

protocol CategoryStoreDelegate: AnyObject {
    func storeDid(change: CategoryStoreChange)
}

final class CategoryStore: NSObject {
    
    private let context: NSManagedObjectContext
    
    private var resultsController: NSFetchedResultsController<CategoryEntity>!
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    private var movedIndexes: Set<CategoryStoreChange.Move>?
    
    weak var delegate: CategoryStoreDelegate?
    
    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()
        
        let request = CategoryEntity.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \CategoryEntity.objectID, ascending: true)
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
}

extension CategoryStore: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
        updatedIndexes = IndexSet()
        movedIndexes = Set<CategoryStoreChange.Move>()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.storeDid(
            change: CategoryStoreChange(
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
                CategoryStoreChange.Move(
                    oldIndex: oldPath.item,
                    newIndex: newPath.item
                )
            )
        @unknown default:
            fatalError("NSFetchedResultsChangeType has unknown default value")
        }
    }
}
