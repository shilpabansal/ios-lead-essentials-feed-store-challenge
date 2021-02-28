//
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest
@testable import FeedStoreChallenge

class FeedStoreIntegrationTests: XCTestCase {
	
	//  ***********************
	//
	//  Uncomment and implement the following tests if your
	//  implementation persists data to disk (e.g., CoreData/Realm)
	//
	//  ***********************
	
	override func setUpWithError() throws {
		try super.setUpWithError()
		
		try setupEmptyStoreState()
	}
	
	override func tearDownWithError() throws {
		try undoStoreSideEffects()
		
		try super.tearDownWithError()
	}
	
	func test_retrieve_deliversEmptyOnEmptyCache() throws {
		let sut = try makeSUT()

		expect(sut, toRetrieve: .empty)
	}
	
	func test_retrieve_deliversFeedInsertedOnAnotherInstance() throws {
		let storeToInsert = try makeSUT()
		let storeToLoad = try makeSUT()
		let feed = uniqueImageFeed()
		let timestamp = Date()

		insert((feed, timestamp), to: storeToInsert)

		expect(storeToLoad, toRetrieve: .found(feed: feed, timestamp: timestamp))
	}
	
	func test_insert_overridesFeedInsertedOnAnotherInstance() throws {
		let storeToInsert = try makeSUT()
		let storeToOverride = try makeSUT()
		let storeToLoad = try makeSUT()

		insert((uniqueImageFeed(), Date()), to: storeToInsert)

		let latestFeed = uniqueImageFeed()
		let latestTimestamp = Date()
		insert((latestFeed, latestTimestamp), to: storeToOverride)

		expect(storeToLoad, toRetrieve: .found(feed: latestFeed, timestamp: latestTimestamp))
	}
	
	func test_delete_deletesFeedInsertedOnAnotherInstance() throws {
		let storeToInsert = try makeSUT()
		let storeToDelete = try makeSUT()
		let storeToLoad = try makeSUT()

		insert((uniqueImageFeed(), Date()), to: storeToInsert)

		deleteCache(from: storeToDelete)

		expect(storeToLoad, toRetrieve: .empty)
	}
	
	// - MARK: Helpers
	
	private func makeSUT() throws -> FeedStore {
		return CoreDataFeedStore()
	}
	
	private func setupEmptyStoreState() throws {
		dataCleanup()
	}
	
	private func undoStoreSideEffects() throws {
		dataCleanup()
	}
	
	func dataCleanup() {
		do {
			if let bundleURL = Bundle(for: CoreDataFeedStore.self).url(forResource: CoreDataFeedStore.modelName, withExtension: "momd") {
					let coreDataInstance = CoreDataStack(storeURL: bundleURL, modelName: CoreDataFeedStore.modelName)
					try coreDataInstance.deleteItems(entityName: FeedsEntity.Cache.rawValue)
					try coreDataInstance.deleteItems(entityName: FeedsEntity.Feed.rawValue)
			}
		}
		catch {
			XCTFail("Unable to delete the data")
		}
	}
}
