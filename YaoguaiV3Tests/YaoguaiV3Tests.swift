//
//  YaoguaiV3Tests.swift
//  YaoguaiV3Tests
//
//  Created by Charles Zhao on 22/8/2024.
//

import XCTest
@testable import YaoguaiV3
import SwiftData

final class YaoguaiV3Tests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
	
	@MainActor
	func testAppStartsEmpty() async throws {
		let config = ModelConfiguration(isStoredInMemoryOnly: true)
		let container = try ModelContainer(for: WorkoutRecord.self, configurations: config)
		let sut = WorkoutManager(modelContext: container.mainContext)
		
		sut.startNewWorkout()
		
		XCTAssertEqual(sut.currentWorkout?.exercises.count, 0, "There should be 0 exercises when starting a workout.")
	}
	
	@MainActor
	func testCanAddExercise() throws {
		let config = ModelConfiguration(isStoredInMemoryOnly: true)
		let container = try ModelContainer(for: WorkoutRecord.self, configurations: config)
		let sut = WorkoutManager(modelContext: container.mainContext)
		
		sut.startNewWorkout()
		
		XCTAssertEqual(sut.currentWorkout?.exercises.count, 0, "There should be 0 exercise at the start.")
		
		let pullups = Exercise(name: "Pullups")
		let record = ExerciseRecord()
		container.mainContext.insert(pullups)
		record.details = pullups
		sut.currentWorkout?.exercises.append(record)
	
		XCTAssertEqual(sut.currentWorkout?.exercises.count, 1, "There should be 1 exercise when adding.")
	}

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
