//
//  CoreDataFeedStore.swift
//  FeedStoreChallenge
//
//  Created by Shilpa Bansal on 23/02/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import CoreData

enum FeedsEntity: String {
	case Feed
	case Cache
}

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
	
	public func deleteItems(entityName: String) throws {
		let context = persistentContainer?.viewContext
		
		let cacheRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
		cacheRequest.includesPropertyValues = false
		
		do {
			if let items = try context?.fetch(cacheRequest) as? [NSManagedObject] {
				items.forEach({ context?.delete($0) })
			}
		} catch let error as NSError {
			throw error
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
}

class CoreDataFeedStore: FeedStore {
	let coreDataInstance = CoreDataStack.sharedInstance
	
	func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		do {
			try coreDataInstance.deleteItems(entityName: FeedsEntity.Cache.rawValue)
			completion(nil)
		} catch let error as NSError {
			completion(error)
		}
	}
	
	func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		guard let managedContext = coreDataInstance.managedContext else { return }
		
		do {
			try coreDataInstance.deleteItems(entityName: FeedsEntity.Cache.rawValue)
			
			if let cacheEntity = NSEntityDescription.entity(forEntityName: FeedsEntity.Cache.rawValue, in: managedContext),
			   let feedEntity = NSEntityDescription.entity(forEntityName: FeedsEntity.Feed.rawValue, in: managedContext) {
				var feeds = [NSManagedObject]()
				
				feed.enumerated().forEach { (index, feedImage) in
					let newNeed = Feed(feedImage: feedImage,
											   managedContext: managedContext,
											   index: index,
											   entityDescription: feedEntity)
					feeds.append(newNeed)
				}
				_ = Cache(timestamp: timestamp,
										   feedObjects: feeds,
										   managedContext: managedContext,
										   entityDescription: cacheEntity)
			}
			completion(nil)
			
		} catch let error as NSError {
			completion(error)
		}
	}
	
	func retrieve(completion: @escaping RetrievalCompletion) {
		do {
			let sortDescriptor = [NSSortDescriptor(key: "index", ascending: true)]
			
			let cacheData = try coreDataInstance.fetchRequest(entityName: FeedsEntity.Cache.rawValue) as? [Cache]
			
			//If the Cache Entity is not empty, then only we need to fetch the records from Feed Entity
			if cacheData?.isEmpty == false, let cache = cacheData?.first,
			   let fetchedFeeds = try coreDataInstance.fetchRequest(entityName: FeedsEntity.Feed.rawValue, sortDescription: sortDescriptor) as? [Feed],
			   let timestamp = cache.timeStamp {
				let imageFeeds = fetchedFeeds.compactMap({
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
