//
//  Cache+CoreDataClass.swift
//  FeedStoreChallenge
//
//  Created by Shilpa Bansal on 24/02/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Cache)
public class Cache: NSManagedObject {
	init(timestamp: Date, feedObjects: [NSManagedObject], managedContext: NSManagedObjectContext, entityDescription: NSEntityDescription) {
		super.init(entity: entityDescription, insertInto: managedContext)
		
		self.setValue(timestamp, forKey: "timeStamp")
		self.setValue(Set(feedObjects), forKey: "feedsEntered")
	}
}
