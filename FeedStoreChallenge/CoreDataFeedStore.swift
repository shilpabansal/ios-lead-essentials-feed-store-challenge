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
	public var coreDataInstance: CoreDataStack?
	
	init() {
		let modelName = "FeedStoreDataModel"
		let bundle = Bundle(identifier: "com.essentialdeveloper.FeedStoreChallenge")
		
		if let bundleURL = bundle?.url(forResource: modelName, withExtension: "momd") {
			coreDataInstance = CoreDataStack(storeURL: bundleURL, modelName: modelName)
		}
	}
		
	func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		do {
			try coreDataInstance?.deleteItems(entityName: FeedsEntity.Cache.rawValue)
			completion(nil)
		} catch let error as NSError {
			completion(error)
		}
	}
	
	func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		guard let managedContext = coreDataInstance?.managedContext else { return }
		
		do {
			try coreDataInstance?.deleteItems(entityName: FeedsEntity.Cache.rawValue)
			
			if let cacheEntity = coreDataInstance?.entityDescription(entityName: FeedsEntity.Cache.rawValue),
			   let feedEntity = coreDataInstance?.entityDescription(entityName: FeedsEntity.Feed.rawValue) {
				let feedManagedObjectArray = feed.enumerated().map { (index, feedImage) -> NSManagedObject in
					Feed(feedImage: feedImage,
						 index: index,
						 managedContext: managedContext,
						 entityDescription: feedEntity)
				}
				_ = Cache(timestamp: timestamp,
						  feedObjects: feedManagedObjectArray,
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
			
			if let cacheData = try coreDataInstance?.fetchRequest(entityName: FeedsEntity.Cache.rawValue) as? [Cache],
			   let cache = cacheData.first,
			   let timestamp = cache.timeStamp,
			   let fetchedFeeds = try coreDataInstance?.fetchRequest(entityName: FeedsEntity.Feed.rawValue, sortDescription: sortDescriptor) as? [Feed] {
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
