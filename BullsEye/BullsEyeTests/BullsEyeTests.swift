//
//  BullsEyeTests.swift
//  BullsEyeTests
//
//  Created by Gleb on 12.12.17.
//  Copyright © 2017 Razeware. All rights reserved.
//

import XCTest

@testable import BullsEye

class BullsEyeTests: XCTestCase {

  var gameUnderTest: BullsEyeGame!

  override func setUp() {
    super.setUp()
    gameUnderTest = BullsEyeGame()
    gameUnderTest.startNewGame()
  }

  override func tearDown() {
    gameUnderTest = nil
    super.tearDown()
  }

  func testScoreIsComputed() {
    let guess = gameUnderTest.targetValue + 5

    _ = gameUnderTest.check(guess: guess)

    XCTAssertEqual(gameUnderTest.score, 95, "Score computed from guess is wrong")
  }

}
