//
//  CoreDataFeedStoreTests.swift
//  Tests
//
//  Created by Shilpa Bansal on 23/02/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import XCTest
@testable import FeedStoreChallenge

class CoreDataFeedStoreTests: XCTestCase, FeedStoreSpecs {
	override func setUpWithError() throws {
		try super.setUpWithError()
		
		try setupEmptyStoreState()
	}
	
	override func tearDownWithError() throws {
		try undoStoreSideEffects()
		
		try super.tearDownWithError()
	}
	
	func test_retrieve_deliversEmptyOnEmptyCache() throws {
		let sut = makeSUT()

		assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
	}
	
	func test_retrieve_hasNoSideEffectsOnEmptyCache() throws {
		let sut = makeSUT()
		
		assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
	}
	
	func test_retrieve_deliversFoundValuesOnNonEmptyCache() throws {
		let sut = makeSUT()
		
		assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
	}
	
	func test_retrieve_hasNoSideEffectsOnNonEmptyCache() throws {
		let sut = makeSUT()

		assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
	}
	
	func test_insert_deliversNoErrorOnEmptyCache() throws {
		let sut = makeSUT()
		
		assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
	}
	
	func test_insert_deliversNoErrorOnNonEmptyCache() throws {
		let sut = makeSUT()
		
		assertThatInsertDeliversNoErrorOnNonEmptyCache(on: sut)
	}
	
	func test_insert_overridesPreviouslyInsertedCacheValues() throws {
		let sut = makeSUT()
		assertThatInsertOverridesPreviouslyInsertedCacheValues(on: sut)
	}
	
	func test_delete_deliversNoErrorOnEmptyCache() throws {
		let sut = makeSUT()
		
		assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
	}
	
	func test_delete_hasNoSideEffectsOnEmptyCache() throws {
		let sut = makeSUT()
		
		assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
	}
	
	func test_delete_deliversNoErrorOnNonEmptyCache() throws {
		let sut = makeSUT()
		
		assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
	}
	
	func test_delete_emptiesPreviouslyInsertedCache() throws {
		let sut = makeSUT()
		
		assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
	}
	
	func test_storeSideEffects_runSerially() throws {
		let sut = makeSUT()
		
		assertThatSideEffectsRunSerially(on: sut)
	}
	
	private func makeSUT() -> CoreDataFeedStore {
		return CoreDataFeedStore()
	}
	
	private func setupEmptyStoreState() throws {
		dataCleanup()
	}
	
	private func undoStoreSideEffects() throws {
		dataCleanup()
	}
}

extension XCTestCase {
	func dataCleanup() {
		let managedContext = CoreDataStack.sharedInstance.managedContext
		if let managedContext = managedContext {
			let cacheRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Cache")
			let feedsRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Feed")

			let batchDeleteCacheRequest = NSBatchDeleteRequest(fetchRequest: cacheRequest)
			let batchDeleteFeedsRequest = NSBatchDeleteRequest(fetchRequest: feedsRequest)
			do {
				try managedContext.execute(batchDeleteCacheRequest)
				try managedContext.execute(batchDeleteFeedsRequest)
				
				try managedContext.save()
			} catch {
			}
		}
	}
}
