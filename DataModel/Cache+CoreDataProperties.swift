//
//  Cache+CoreDataProperties.swift
//  FeedStoreChallenge
//
//  Created by Shilpa Bansal on 24/02/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//
//

import Foundation
import CoreData


extension Cache {

    @nonobjc class func fetchRequest() -> NSFetchRequest<Cache> {
        return NSFetchRequest<Cache>(entityName: "Cache")
    }

    @NSManaged var timeStamp: Date
    @NSManaged var feedsEntered: NSOrderedSet

}

// MARK: Generated accessors for feedsEntered
extension Cache {

    @objc(addFeedsEnteredObject:)
    @NSManaged func addToFeedsEntered(_ value: Feed)

    @objc(removeFeedsEnteredObject:)
    @NSManaged func removeFromFeedsEntered(_ value: Feed)

    @objc(addFeedsEntered:)
    @NSManaged func addToFeedsEntered(_ values: NSOrderedSet)

    @objc(removeFeedsEntered:)
    @NSManaged func removeFromFeedsEntered(_ values: NSOrderedSet)

}

extension Cache : Identifiable {

}
