//
//  CoreDataFeedStoreTests.swift
//  Tests
//
//  Created by Shilpa Bansal on 23/02/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import XCTest
import FeedStoreChallenge

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
		let sut = try makeSUT()

		assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
	}
	
	func test_retrieve_hasNoSideEffectsOnEmptyCache() throws {
		let sut = try makeSUT()
		
		assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
	}
	
	func test_retrieve_deliversFoundValuesOnNonEmptyCache() throws {
		let sut = try makeSUT()
		
		assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
	}
	
	func test_retrieve_hasNoSideEffectsOnNonEmptyCache() throws {
		let sut = try makeSUT()

		assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
	}
	
	func test_insert_deliversNoErrorOnEmptyCache() throws {
		let sut = try makeSUT()
		
		assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
	}
	
	func test_insert_deliversNoErrorOnNonEmptyCache() throws {
		let sut = try makeSUT()
		
		assertThatInsertDeliversNoErrorOnNonEmptyCache(on: sut)
	}
	
	func test_insert_overridesPreviouslyInsertedCacheValues() throws {
		let sut = try makeSUT()
		assertThatInsertOverridesPreviouslyInsertedCacheValues(on: sut)
	}
	
	func test_delete_deliversNoErrorOnEmptyCache() throws {
		let sut = try makeSUT()
		
		assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
	}
	
	func test_delete_hasNoSideEffectsOnEmptyCache() throws {
		let sut = try makeSUT()
		
		assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
	}
	
	func test_delete_deliversNoErrorOnNonEmptyCache() throws {
		let sut = try makeSUT()
		
		assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
	}
	
	func test_delete_emptiesPreviouslyInsertedCache() throws {
		let sut = try makeSUT()
		
		assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
	}
	
	func test_storeSideEffects_runSerially() throws {
		let sut = try makeSUT()
		
		assertThatSideEffectsRunSerially(on: sut)
	}
	
	private func makeSUT() throws -> CoreDataFeedStore {
		do {
			guard let bundleURL = Bundle(for: CoreDataFeedStore.self).url(forResource: CoreDataFeedStore.modelName, withExtension: "momd") else {
				throw NSError(domain: "Bundle URL is nil", code: 0, userInfo: nil)
			}
//			let storeURL = URL(fileURLWithPath: "/dev/null")
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
