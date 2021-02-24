//
//  CoreDataFeedStore.swift
//  FeedStoreChallenge
//
//  Created by Shilpa Bansal on 23/02/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import CoreData

public class CoreDataStack {
	public static let sharedInstance = CoreDataStack()
	let model: String       = "FeedStoreDataModel"
	
	var persistentStoreURL: URL? {
		let bundle = Bundle(identifier: "com.essentialdeveloper.FeedStoreChallenge")
		return bundle?.url(forResource: model, withExtension: "momd")
	}
	
	lazy var persistentContainer: NSPersistentContainer? = {
		var container: NSPersistentContainer?
		if let modelURL = persistentStoreURL {
			let managedObjectModel =  NSManagedObjectModel(contentsOf: modelURL)
			container = NSPersistentContainer(name: model, managedObjectModel: managedObjectModel!)
		}
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
	
	public func saveContext() {
		let context = persistentContainer?.viewContext
		if context?.hasChanges == true {
			do {
				try context?.save()
			} catch let error as NSError {
				fatalError("Unresolved error \(error), \(error.userInfo)")
			}
		}
	}
}

class CoreDataFeedStore: FeedStore {
	
	func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		let managedContext = CoreDataStack.sharedInstance.managedContext
		if let managedContext = managedContext {
			let cacheRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Cache")
			
			cacheRequest.includesPropertyValues = false
			
			do {
				let items = try managedContext.fetch(cacheRequest) as! [Cache]

				for item in items {
					managedContext.delete(item)
				}
				
				try managedContext.save()
				completion(nil)

			} catch {
				completion(error)
			}
		}
	}
	
	func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		deleteCachedFeed { (error) in
			if let error = error {
				completion(error)
				return
			}
			
			let managedContext = CoreDataStack.sharedInstance.managedContext
			if let managedContext = managedContext {
				var feeds = [NSManagedObject]()
				
				let cacheObject = NSEntityDescription.insertNewObject(forEntityName: "Cache", into: managedContext)
				cacheObject.setValue(timestamp, forKey: "timeStamp")
				
				feed.enumerated().forEach { (index, feedImage) in
					let feedObject = NSEntityDescription.insertNewObject(forEntityName: "Feed", into: managedContext)
					
					feedObject.setValue(index, forKey: "index")
					feedObject.setValue(feedImage.id, forKey: "feed_id")
					feedObject.setValue(feedImage.location, forKey: "feed_location")
					feedObject.setValue(feedImage.description, forKey: "feed_description")
					feedObject.setValue(feedImage.url, forKey: "feed_url")
					
					feedObject.setValue(cacheObject, forKey: "timeStamp")
					
					feeds.append(feedObject)
				}
				
				cacheObject.setValue(NSSet(array: feeds), forKey: "feedsEntered")
				
				do {
					try managedContext.save()
					completion(nil)
				}
				catch {
					completion(error)
				}
			}
		}
	}
	
	func retrieve(completion: @escaping RetrievalCompletion) {
		let managedContext = CoreDataStack.sharedInstance.managedContext
		if let managedContext = managedContext {
			let cacheRequest : NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Cache")
			let feedRequest : NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Feed")
			
			let sort = NSSortDescriptor(key: "index", ascending: true)
			feedRequest.sortDescriptors = [sort]
			
			do {
				if let cache = try managedContext.fetch(cacheRequest).first as? Cache,
				   let feeds = try managedContext.fetch(feedRequest) as? [Feed],
				   let timestamp = cache.timeStamp {
					let imageFeeds = feeds.compactMap({
						return $0.feedImage
					})
						
					completion(.found(feed: imageFeeds, timestamp: timestamp))
				}
				else {
					completion(.empty)
				}
			} catch let error as NSError {
				completion(.failure(error))
			}
		}
	}
}

extension Feed {
	var feedImage: LocalFeedImage? {
		guard let id = feed_id, let url = feed_url else { return nil }
		return LocalFeedImage(id: id, description: feed_description, location: feed_location, url: url)
	}
}
