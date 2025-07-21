import CoreData
import Foundation

@MainActor
class PersistenceController: ObservableObject {
    static let shared = PersistenceController()
    
    lazy var container: NSPersistentContainer = {
        // Swift Package Manager環境では.xcdatamodeldファイルの読み込みに問題があるため
        // 一時的にin-memoryストアを使用
        let container = NSPersistentContainer(name: "AsatsuyuDataModel")
        
        // In-memory storeを使用（開発段階）
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                // エラーをログに出力するが、アプリをクラッシュさせない
                print("Core Data error: \(error), \(error.userInfo)")
                print("Using in-memory store for development")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }
    
    func save() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Core Data save error: \(nsError), \(nsError.userInfo)")
            }
        }
    }
}