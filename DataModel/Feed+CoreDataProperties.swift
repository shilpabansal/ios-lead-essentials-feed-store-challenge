//
//  Feed+CoreDataProperties.swift
//  FeedStoreChallenge
//
//  Created by Shilpa Bansal on 24/02/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//
//

import Foundation
import CoreData

extension Feed {
    @nonobjc class func fetchRequest() -> NSFetchRequest<Feed> {
        return NSFetchRequest<Feed>(entityName: "Feed")
    }

    @NSManaged var feed_description: String?
    @NSManaged var feed_id: UUID
    @NSManaged var feed_location: String?
    @NSManaged var feed_url: URL
    @NSManaged var cache: Cache
}

extension Feed : Identifiable {

}

extension Feed {
	var feedImage: LocalFeedImage? {
		return LocalFeedImage(id: feed_id, description: feed_description, location: feed_location, url: feed_url)
	}
}
