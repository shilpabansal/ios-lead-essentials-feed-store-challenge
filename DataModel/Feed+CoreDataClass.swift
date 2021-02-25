//
//  Feed+CoreDataClass.swift
//  FeedStoreChallenge
//
//  Created by Shilpa Bansal on 24/02/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Feed)
public class Feed: NSManagedObject {
	init(feedImage: LocalFeedImage, index: Int, managedContext: NSManagedObjectContext, entityDescription: NSEntityDescription) {
		super.init(entity: entityDescription, insertInto: managedContext)
		
		self.setValue(index, forKey: "index")
		self.setValue(feedImage.id, forKey: "feed_id")
		self.setValue(feedImage.location, forKey: "feed_location")
		self.setValue(feedImage.description, forKey: "feed_description")
		self.setValue(feedImage.url, forKey: "feed_url")
	}
}
