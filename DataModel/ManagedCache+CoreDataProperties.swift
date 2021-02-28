//
//  ManagedCache+CoreDataProperties.swift
//  FeedStoreChallenge
//
//  Created by Shilpa Bansal on 24/02/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//
//

import Foundation
import CoreData


extension ManagedCache {
	static func entityName() -> String {
		return "ManagedCache"
	}
	
    @nonobjc class func fetchRequest() -> NSFetchRequest<ManagedCache> {
        return NSFetchRequest<ManagedCache>(entityName: entityName())
    }

    @NSManaged var timeStamp: Date
    @NSManaged var feedsEntered: NSOrderedSet

}

// MARK: Generated accessors for feedsEntered
extension ManagedCache {

    @objc(addFeedsEnteredObject:)
    @NSManaged func addToFeedsEntered(_ value: ManagedFeedImage)

    @objc(removeFeedsEnteredObject:)
    @NSManaged func removeFromFeedsEntered(_ value: ManagedFeedImage)

    @objc(addFeedsEntered:)
    @NSManaged func addToFeedsEntered(_ values: NSOrderedSet)

    @objc(removeFeedsEntered:)
    @NSManaged func removeFromFeedsEntered(_ values: NSOrderedSet)

}

extension ManagedCache : Identifiable {
	static func find(in context: NSManagedObjectContext) throws -> ManagedCache? {
		let request = NSFetchRequest<ManagedCache>(entityName: entityName())
		return try context.fetch(request).first
	}
	
	static func uniqueNewInstance(in context: NSManagedObjectContext, timestamp: Date) throws -> ManagedCache {
		try find(in: context).map(context.delete)
		
		let cache = ManagedCache(context: context)
		cache.timeStamp = timestamp
		return cache
	}
}
