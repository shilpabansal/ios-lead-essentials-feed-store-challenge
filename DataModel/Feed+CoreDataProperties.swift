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
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Feed> {
        return NSFetchRequest<Feed>(entityName: "Feed")
    }

	@NSManaged public var index: Int
    @NSManaged public var feed_description: String?
    @NSManaged public var feed_id: UUID?
    @NSManaged public var feed_location: String?
    @NSManaged public var feed_url: URL?
    @NSManaged public var timeStamp: Cache?
}

extension Feed : Identifiable {

}

extension Feed {
	var feedImage: LocalFeedImage? {
		guard let id = feed_id, let url = feed_url else { return nil }
		return LocalFeedImage(id: id, description: feed_description, location: feed_location, url: url)
	}
}
