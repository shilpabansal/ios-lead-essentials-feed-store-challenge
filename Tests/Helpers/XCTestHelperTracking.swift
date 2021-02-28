//
//  XCTestHelperTracking.swift
//  Tests
//
//  Created by Shilpa Bansal on 28/02/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import XCTest

public extension XCTestCase {
	func trackMemoryLeak(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
		addTeardownBlock {[weak instance] in
			XCTAssertNil(instance, "Instance should be deallocated, potential memory leak", file: file, line: line)
		}
	}
}
