//
//  NSDate+ExtensionsTests.swift
//  ChouTi_FrameworkTests
//
//  Created by Honghao Zhang on 2015-12-13.
//  Copyright © 2015 Honghao Zhang. All rights reserved.
//

import XCTest
@testable import ChouTi

class NSDate_ExtensionsTests: XCTestCase {
	
	override func setUp() {
		super.setUp()
	}
	
	override func tearDown() {
		super.tearDown()
	}
	
	func testForSettingUnit() {
		let date = Date()
		let dateWithUpdatedYear = date.date(bySetting: .year, with: 1900)
		XCTAssertEqual(dateWithUpdatedYear?.year, 1900)
	}
}
