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
	let coreDataStack: CoreDataStack
	public static let modelName = "FeedStoreDataModel"
	
	init() {
		if let bundleURL = Bundle(for: Self.self).url(forResource: CoreDataFeedStore.modelName, withExtension: "momd") {
			coreDataStack = CoreDataStack(storeURL: bundleURL, modelName: CoreDataFeedStore.modelName)
		}
		else {
			fatalError("Failed to fetch the Datamodel")
		}
	}
	
	func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		do {
			try coreDataStack.deleteItems(entityName: FeedsEntity.Cache.rawValue)
			completion(nil)
		} catch let error as NSError {
			completion(error)
		}
	}
	
	func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		guard let managedContext = coreDataStack.managedContext,
			  let cacheEntity = coreDataStack.entityDescription(entityName: FeedsEntity.Cache.rawValue),
			let feedEntity = coreDataStack.entityDescription(entityName: FeedsEntity.Feed.rawValue) else { return }
		
		do {
			try coreDataStack.deleteItems(entityName: FeedsEntity.Cache.rawValue)
			
			let cacheObject = Cache(entity: cacheEntity, insertInto: managedContext)
			cacheObject.timeStamp = timestamp

			try feed.forEach { feedImage in
				let feedObject = Feed(entity: feedEntity, insertInto: managedContext)
				feedObject.cache = cacheObject
				feedObject.feed_id = feedImage.id
				feedObject.feed_location = feedImage.location
				feedObject.feed_description = feedImage.description
				feedObject.feed_url = feedImage.url
				
				cacheObject.addToFeedsEntered(feedObject)
				
				try coreDataStack.saveContext()
			}
			
			completion(nil)
		} catch {
			completion(error)
		}
	}
	
	func retrieve(completion: @escaping RetrievalCompletion) {
		do {
			if let cacheData = try coreDataStack.fetchRequest(entityName: FeedsEntity.Cache.rawValue) as? [Cache],
			   let cacheObject = cacheData.first,
			   let fetchedFeeds = try coreDataStack.fetchRequest(entityName: FeedsEntity.Feed.rawValue) as? [Feed] {
				let imageFeeds = fetchedFeeds.compactMap({
					return $0.feedImage
				})
				completion(.found(feed: imageFeeds, timestamp: cacheObject.timeStamp))
			}
			else {
				completion(.empty)
			}
		} catch let error as NSError {
			completion(.failure(error))
		}
	}
}
