//
//  CoreDataFeedStore.swift
//  FeedStoreChallenge
//
//  Created by Shilpa Bansal on 23/02/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import CoreData

public class CoreDataFeedStore: FeedStore {
	private let persistentContainer: NSPersistentContainer
	private let managedContext: NSManagedObjectContext
	private let modelName = "FeedStoreDataModel"
	
	public init(storeURL: URL) throws {
		let storeBundle = Bundle(for: CoreDataFeedStore.self)
		
		guard let model = NSManagedObjectModel.with(name: modelName, in: storeBundle) else {
			throw NSError(domain: "Couldn't find the object model in Bundle", code: 0, userInfo: nil)
		}
		
		persistentContainer = NSPersistentContainer(name: modelName, managedObjectModel: model)
		
		try persistentContainer.load(storeURL: storeURL)
		managedContext = persistentContainer.newBackgroundContext()
	}
	
	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		perform { context in
			do {
				try ManagedCache.find(in: context).map(context.delete).map(context.save)
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
		perform { context in
			do {
				let managedCache = try ManagedCache.uniqueNewInstance(in: context, timestamp: timestamp)
				managedCache.feedsEntered = ManagedFeedImage.feedImages(from: feed, in: context)

				try context.save()
				completion(nil)
			} catch {
				completion(error)
			}
		}
	}
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
		perform { context in
			do {
				if let cache = try ManagedCache.find(in: context) {
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

extension NSManagedObjectModel {
	static func with(name: String, in bundle: Bundle) -> NSManagedObjectModel? {
		return bundle
			.url(forResource: name, withExtension: "momd")
			.flatMap { NSManagedObjectModel(contentsOf: $0) }
	}
	
	static func urlWith(name: String, in bundle: Bundle) -> URL? {
		return bundle
			.url(forResource: name, withExtension: "momd")
	}
}

extension NSPersistentContainer {
	func load(storeURL: URL) throws {
		let description = NSPersistentStoreDescription(url: storeURL)
		self.persistentStoreDescriptions = [description]
		
		var loadError: Swift.Error?
		loadPersistentStores { loadError = $1 }
		
		if let loadError = loadError {
			throw loadError
		}
	}
}
