//
//  CoreDataStack.swift
//  FeedStoreChallenge
//
//  Created by Shilpa Bansal on 25/02/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import CoreData

public class CoreDataStack {
	var modelName: String
	var persistentStoreURL: URL
	
	public init(storeURL: URL, modelName: String) {
		persistentStoreURL = storeURL
		self.modelName = modelName
	}
	
	lazy var persistentContainer: NSPersistentContainer? = {
		var container: NSPersistentContainer?
		
		let managedObjectModel =  NSManagedObjectModel(contentsOf: persistentStoreURL)
		container = NSPersistentContainer(name: modelName, managedObjectModel: managedObjectModel!)
		
		container?.loadPersistentStores(completionHandler: { (storeDescription, error) in
			if let error = error {
				return
			}
		})
		return container
	}()

	var managedContext: NSManagedObjectContext? {
		return persistentContainer?.viewContext
	}
	
	public func deleteItems(entityName: String) throws {
		let context = persistentContainer?.viewContext
		
		let cacheRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
		cacheRequest.includesPropertyValues = false
		
		do {
			if let items = try context?.fetch(cacheRequest) as? [NSManagedObject] {
				items.forEach({ context?.delete($0) })
			}
			
			try context?.save()
		} catch let error as NSError {
			throw error
		}
	}
	
	func saveContext() throws {
		let context = persistentContainer?.viewContext
		if context?.hasChanges == true {
			do {
				try context?.save()
			} catch {
				throw error
			}
		}
	}
	
	public func fetchRequest(entityName: String,
							 sortDescription: [NSSortDescriptor]? = nil) throws -> [NSManagedObject]? {
		let context = persistentContainer?.viewContext
		let cacheRequest : NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
		cacheRequest.sortDescriptors = sortDescription
		
		do {
			return try context?.fetch(cacheRequest) as? [NSManagedObject]
		} catch let error as NSError {
			throw error
		}
	}
	
	public func entityDescription(entityName: String) -> NSEntityDescription? {
		if let context = persistentContainer?.viewContext {
			return NSEntityDescription.entity(forEntityName: entityName, in: context)
		}
		return nil
	}
}
