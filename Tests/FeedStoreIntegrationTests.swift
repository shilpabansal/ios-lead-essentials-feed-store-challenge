//
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest
import FeedStoreChallenge

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
		do {
			guard let bundleURL = Bundle(for: CoreDataFeedStore.self).url(forResource: CoreDataFeedStore.modelName, withExtension: "momd") else {
				throw NSError(domain: "Bundle URL is nil", code: 0, userInfo: nil)
			}
			let sut = try CoreDataFeedStore(bundleURL: bundleURL)
			trackMemoryLeak(sut)
			return sut
		}
		catch {
			throw NSError(domain: "Unable to create instance", code: 0, userInfo: nil)
		}
	}
	
	private func setupEmptyStoreState() throws {
		dataCleanup()
	}
	
	private func undoStoreSideEffects() throws {
		dataCleanup()
	}
	
	func dataCleanup() {
		let url = Bundle(for: CoreDataFeedStore.self).url(forResource: CoreDataFeedStore.modelName, withExtension: "momd")
		
		if let managedObjectModel = url.map({NSManagedObjectModel(contentsOf: $0)}) as? NSManagedObjectModel {
			let persistentContainer = NSPersistentContainer(name: CoreDataFeedStore.modelName, managedObjectModel: managedObjectModel)
			
			let exp = expectation(description: "Wait for loading")
			persistentContainer.loadPersistentStores {desc, error  in
				let context = persistentContainer.newBackgroundContext()
				context.perform {
					do {
						try ManagedCache.find(in: context).map(context.delete).map(context.save)
					}
					catch {
						XCTFail("Unable to delete the data")
					}
					exp.fulfill()
				}
			}
			wait(for: [exp], timeout: 1.0)
		}
	}
}
