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
	private func makeSUT(file: StaticString = #file, line: UInt = #line) throws -> FeedStore {
		let sut = try CoreDataFeedStore(storeURL: testSpecificURL())
		trackMemoryLeak(sut, file: file, line: line)
		return sut
	}
	
	private func setupEmptyStoreState() throws {
		try dataCleanup()
	}
	
	private func undoStoreSideEffects() throws {
		try dataCleanup()
	}
	
	private func testSpecificURL() -> URL {
		let storeDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
		return storeDirectory.appendingPathComponent("FeedStoreDataModel.sqlite")
	}
	
	private func dataCleanup(file: StaticString = #file, line: UInt = #line) throws {
		deleteCache(from: try CoreDataFeedStore(storeURL: testSpecificURL()))
	}
}
