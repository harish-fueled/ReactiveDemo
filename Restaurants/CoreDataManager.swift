//
//  CoreDataManager.swift
//  Restaurants
//
//  Created by Ankit on 16/05/16.
//  Copyright © 2016 Fueled. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager: NSObject {
	struct Constant {
		static let modelFileName = "Restaurants"
	}

	static let shared: CoreDataManager = CoreDataManager()
	
	lazy var applicationDocumentsDirectory: URL = {
		let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		return urls.last!
	}()
	
	lazy var managedObjectModel: NSManagedObjectModel = {
		let modelURL = Bundle.main.url(forResource: CoreDataManager.Constant.modelFileName, withExtension: "momd")!
		return NSManagedObjectModel(contentsOf: modelURL)!
	}()
	
	lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
		var persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
		let storeUrl = self.applicationDocumentsDirectory.appendingPathComponent("\(CoreDataManager.Constant.modelFileName).sqlite")
		do {
			let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
			try persistentStoreCoordinator.addPersistentStore(
				ofType: NSSQLiteStoreType,
				configurationName: nil,
				at: storeUrl, options: options)
		} catch {
			print("Error while creating Local Persistent store: \((error as NSError).userInfo)")
		}
		return persistentStoreCoordinator
	}()
	
	lazy var mainManagedObjectContext: NSManagedObjectContext = {
		var context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
		context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
		context.persistentStoreCoordinator = self.persistentStoreCoordinator
		return context
	}()
	
	var backgroundManagedObjectContext: NSManagedObjectContext {
		let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
		context.persistentStoreCoordinator = self.persistentStoreCoordinator
		return context
	}
	
	// MARK: - Object Fetch Methods
	
	func objectsForEntityName<T: NSManagedObject>(
		_ entityName: String,
		predicate: NSPredicate? = nil,
		sortDescriptors: [NSSortDescriptor]? = nil,
		inContext context: NSManagedObjectContext? = nil) throws -> [T] {
		let managedContext = context ?? self.mainManagedObjectContext
		
		let entity = NSEntityDescription.entity(
			forEntityName: entityName,
			in: managedContext)
		let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
		request.entity = entity
		request.predicate = predicate
		request.sortDescriptors = sortDescriptors
		
		var objects: [T] = []
		do {
			objects = try managedContext.fetch(request) as! [T]
		} catch let catchedError as NSError {
			throw catchedError
		}
		return objects
	}
	
	func countOfObjects(
		for entityName: String,
		predicate: NSPredicate? = nil,
		inContext context: NSManagedObjectContext? = nil) -> Int
	{
		let managedContext = context ?? self.mainManagedObjectContext
		let entity = NSEntityDescription.entity(forEntityName: entityName, in: managedContext)
		let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
		request.entity = entity
		request.predicate = predicate
		
		do {
			return try managedContext.count(for: request)
		} catch {
			return 0
		}
	}
	
	func newObject<T: NSManagedObject>(for entityName: String, in context: NSManagedObjectContext? = nil) -> T {
		let managedContext = context ?? self.mainManagedObjectContext
		let newObject = NSEntityDescription.insertNewObject(forEntityName: entityName, into: managedContext)
		return newObject as! T
	}
	
	// MARK: - Object Delete Methods
	
	func deleteObjects(_ objectsToBeDeleted: [NSManagedObject]) {
		for object in objectsToBeDeleted {
			if object.managedObjectContext != nil {
				self.mainManagedObjectContext.delete(object)
			}
		}
		self.saveContext()
	}
	
	func deleteObject(_ objectToBeDeleted: NSManagedObject) {
		self.deleteObjects([objectToBeDeleted])
	}
	
	func deleteObjects(for entityName: String, predicate: NSPredicate? = nil) {
		do {
			let objectsToBeDeleted = try self.objectsForEntityName(entityName, predicate: predicate)
			self.deleteObjects(objectsToBeDeleted)
		} catch let error as NSError {
			print("error thrown while fetching entity objects error: \(error.localizedDescription) for \(entityName)")
		}
	}
	
	func deleteAllUnlinkObjectsOfEntity(entityName: String) {
		let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
		let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
		do {
			try self.mainManagedObjectContext.execute(deleteRequest)
		} catch let error as NSError {
			print("error thrown while deleting entity objects error: \(error.localizedDescription) for \(entityName)")
		}
	}
	
	// MARK: - Core Data Saving support

	func saveContext() {
		do {
			self.mainManagedObjectContext.refreshAllObjects()
			try self.mainManagedObjectContext.save()
		} catch {
			print("error while saving main managed object context: \(error)")
		}
	}
}

extension CoreDataManager {
	class func newObject<T: NSManagedObject>(entityName: String) -> T {
		let object = NSEntityDescription.insertNewObject(forEntityName: entityName, into: self.shared.mainManagedObjectContext) as! T
		return object
	}
	
	class func object<T: NSManagedObject>(entityName: String, pkey: String, value: String) -> T {
		var object: T
		if let existingObject = objectForKeyValue(entityName: entityName, key: pkey, value: value) as? T {
			object = existingObject
		} else {
			object = newObject(entityName: entityName)
		}
		return object
	}
	
	class func objectForKeyValue<T: NSManagedObject>(entityName: String, key: String, value: String) -> T? {
		return objectsForKeyValue(entityName: entityName, key: key, value: value).first
	}
	
	class func objectsForKeyValue<T: NSManagedObject>(entityName: String, key: String, value: String) -> [T] {
		let predicate =  NSPredicate(format: "\(key) = %@", value)
		let objects = self.objects(for: entityName, sortDescriptors: nil, predicate: predicate)
		return objects as! [T]
	}
	
	class func objects<T: NSManagedObject>(for entityName: String, sortDescriptors: [NSSortDescriptor]? = nil, predicate: NSPredicate? = nil, fetchLimit: Int? = nil) -> [T] {
		var result: [NSManagedObject] = []
		if let fetchRequest = fetchRequestGenerator(for: entityName, sortDescriptors: sortDescriptors, predicate: predicate, fetchLimit: fetchLimit) {
			do {
				result = try self.shared.mainManagedObjectContext.fetch(fetchRequest)
			} catch {
				result = []
			}
		}
		return result as! [T]
	}
}

private extension CoreDataManager {
	class func fetchRequestGenerator(for entityName: String, sortDescriptors: [NSSortDescriptor]?, predicate: NSPredicate?, fetchLimit: Int?)
		-> NSFetchRequest<NSManagedObject>?
	{
		let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
		if let fetchLimit = fetchLimit {
			fetchRequest.fetchLimit = fetchLimit
		}
		let entity = NSEntityDescription.entity(forEntityName: entityName, in: self.shared.mainManagedObjectContext)
		fetchRequest.entity = entity
		fetchRequest.sortDescriptors = sortDescriptors
		fetchRequest.predicate = predicate
		return fetchRequest
	}
}
