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

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Cache> {
        return NSFetchRequest<Cache>(entityName: "Cache")
    }

    @NSManaged public var timeStamp: Date?
    @NSManaged public var feedsEntered: NSSet?

}

// MARK: Generated accessors for feedsEntered
extension Cache {

    @objc(addFeedsEnteredObject:)
    @NSManaged public func addToFeedsEntered(_ value: Feed)

    @objc(removeFeedsEnteredObject:)
    @NSManaged public func removeFromFeedsEntered(_ value: Feed)

    @objc(addFeedsEntered:)
    @NSManaged public func addToFeedsEntered(_ values: NSSet)

    @objc(removeFeedsEntered:)
    @NSManaged public func removeFromFeedsEntered(_ values: NSSet)

}

extension Cache : Identifiable {

}
