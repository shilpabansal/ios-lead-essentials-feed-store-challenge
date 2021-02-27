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

class CoreDataFeedStore: FeedStore {
	public var coreDataStack: CoreDataStack?
	public let modelName = "FeedStoreDataModel"
	
	init() {
		if let bundleURL = Bundle(for: Self.self).url(forResource: modelName, withExtension: "momd") {
			coreDataStack = CoreDataStack(storeURL: bundleURL, modelName: modelName)
		}
		else {
			fatalError("Failed to fetch the Datamodel")
		}
	}
	
	func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		do {
			try coreDataStack?.deleteItems(entityName: FeedsEntity.Cache.rawValue)
			completion(nil)
		} catch let error as NSError {
			completion(error)
		}
	}
	
	func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		guard let managedContext = coreDataStack?.managedContext else { return }
		
		do {
			try coreDataStack?.deleteItems(entityName: FeedsEntity.Cache.rawValue)
			
			let cacheObject = NSEntityDescription.insertNewObject(forEntityName: "Cache", into: managedContext)
			cacheObject.setValue(timestamp, forKey: "timeStamp")

			let feedManagedObjectArray = feed.enumerated().map { (index, feedImage) -> NSManagedObject in
				let feedObject = NSEntityDescription.insertNewObject(forEntityName: "Feed", into: managedContext)

				feedObject.setValue(index, forKey: "index")
				feedObject.setValue(feedImage.id, forKey: "feed_id")
				feedObject.setValue(feedImage.location, forKey: "feed_location")
				feedObject.setValue(feedImage.description, forKey: "feed_description")
				feedObject.setValue(feedImage.url, forKey: "feed_url")

				feedObject.setValue(cacheObject, forKey: "timeStamp")
				return feedObject
			}
			
			cacheObject.setValue(NSSet(array: feedManagedObjectArray), forKey: "feedsEntered")
			
			try coreDataStack?.saveContext()
			completion(nil)
		} catch {
			completion(error)
		}
	}
	
	func retrieve(completion: @escaping RetrievalCompletion) {
		do {
			let sortDescriptor = [NSSortDescriptor(key: "index", ascending: true)]
			
			if let cacheData = try coreDataStack?.fetchRequest(entityName: FeedsEntity.Cache.rawValue) as? [Cache],
			   let cache = cacheData.first,
			   let timestamp = cache.timeStamp,
			   let fetchedFeeds = try coreDataStack?.fetchRequest(entityName: FeedsEntity.Feed.rawValue, sortDescription: sortDescriptor) as? [Feed] {
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
