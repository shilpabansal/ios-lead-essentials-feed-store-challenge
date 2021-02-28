//
//  CoreDataFeedStore.swift
//  FeedStoreChallenge
//
//  Created by Shilpa Bansal on 23/02/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import CoreData

public enum FeedsEntity: String {
	case ManagedFeedImage
	case ManagedCache
}

public class CoreDataFeedStore: FeedStore {
	let persistentContainer: NSPersistentContainer
	let managedContext: NSManagedObjectContext
	public static let modelName = "FeedStoreDataModel"
	
	public init(bundleURL: URL) throws {
		guard let managedObjectModel = NSManagedObjectModel(contentsOf: bundleURL) else {
			throw NSError(domain: "Couldnt find the model", code: 0)
		}
		
		persistentContainer = NSPersistentContainer(name: CoreDataFeedStore.modelName, managedObjectModel: managedObjectModel)
		
		var loadError: Error?
		persistentContainer.loadPersistentStores{ loadError = $1 }
		
		if let loadError = loadError {
			throw loadError
		}
		managedContext = persistentContainer.newBackgroundContext()
	}
	
	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		perform {[weak managedContext] _ in
			guard let managedContext = managedContext else {
				completion(NSError(domain: "Instance not found", code: 0))
				return
			}
			do {
				try ManagedCache.find(in: managedContext).map(managedContext.delete).map(managedContext.save)
				completion(nil)
			}
			catch {
				completion(error)
			}
		}
	}
	
	private func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
		let managedContext = self.managedContext
		managedContext.perform { action(managedContext) }
	}
	
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		perform {[weak managedContext] _ in
			guard let managedContext = managedContext else {
				completion(NSError(domain: "Instance not found", code: 0))
				return
			}
			do {
				let managedCache = try ManagedCache.uniqueNewInstance(in: managedContext, timestamp: timestamp)
				managedCache.feedsEntered = ManagedFeedImage.feedImages(from: feed, in: managedContext)

				try managedContext.save()
				completion(nil)
			} catch {
				completion(error)
			}
		}
	}
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
		perform {[weak managedContext] _ in
			guard let managedContext = managedContext else {
				completion(.failure(NSError(domain: "Instance not found", code: 0)))
				return
			}
			do {
				if let cache = try ManagedCache.find(in: managedContext) {
					let feedArray = cache.feedsEntered.compactMap { ($0 as? ManagedFeedImage)?.feedImage }
					completion(.found(feed: feedArray, timestamp: cache.timeStamp))
				}
				else {
					completion(.empty)
				}
				
			} catch {
				completion(.failure(error))
			}
		}
	}
}
