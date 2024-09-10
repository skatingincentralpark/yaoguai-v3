//
//  YaoguaiV3Tests.swift
//  YaoguaiV3Tests
//
//  Created by Charles Zhao on 22/8/2024.
//

import XCTest
@testable import YaoguaiV3
import SwiftData

final class WorkoutManagerTests: XCTestCase {
	// MARK: - Setup / Teardown
	let savePath = URL.documentsDirectory.appending(path: "CurrentWorkout")
	
	override func setUp() async throws {
		if FileManager.default.fileExists(atPath: savePath.path) {
			try FileManager.default.removeItem(at: savePath)
		}
	}
	
	override func tearDown() async throws {
		if FileManager.default.fileExists(atPath: savePath.path) {
			try FileManager.default.removeItem(at: savePath)
		}
	}

	// MARK: - Tests
	
	//	Should initialise with no data
	@MainActor
	func testInitialise() async throws {
		let container = try await createContainer()
		let workoutManager = try await setup(with: container)
		
		// When: the app starts and we check initial state
		let currentWorkout = workoutManager.currentWorkout
		let currentWorkoutId = workoutManager.currentWorkoutId
		let savedWorkoutExists = FileManager.default.fileExists(atPath: savePath.path)
		let workoutRecordsInDB = try fetchModelCount(ofType: WorkoutRecord.self, in: container.mainContext)
		
		// Then: assert that the initial state is as expected
		XCTAssertNil(currentWorkout, "Expected no current workout on initial load")
		XCTAssertNil(currentWorkoutId, "Expected no current workout ID on initial load")
		XCTAssertFalse(savedWorkoutExists, "Expected no saved workout file on initial load")
		XCTAssertEqual(workoutRecordsInDB, 0, "Expected no workout records in the database on initial load")
	}
	
	//	Should be able to start a new workout
	@MainActor
	func testStartWorkout() async throws {
		let container = try await createContainer()
		let workoutManager = try await setup(with: container)
		
		workoutManager.startNewWorkout()
		
		let newCurrentWorkout = workoutManager.currentWorkout
		let newCurrentWorkoutId = workoutManager.currentWorkoutId
		let newSavedWorkoutExists = FileManager.default.fileExists(atPath: savePath.path)
		let workoutRecordsInDB = try fetchModelCount(ofType: WorkoutRecord.self, in: container.mainContext)
		
		// Then: assert that the initial state is as expected
		XCTAssertNotNil(newCurrentWorkout, "Expected current workout after starting a workout")
		XCTAssertNotNil(newCurrentWorkoutId, "Expected current workout ID after starting a workout")
		XCTAssertTrue(newSavedWorkoutExists, "Expected saved workout file after starting a workout")
		XCTAssertEqual(workoutRecordsInDB, 1, "Expected 1 workout record in the database after starting a workout")
	}
	
	// Starting a workout can restore an ongoing workout
	@MainActor
	func testRestoreWorkout() async throws {
		let container = try await createContainer()
		let workoutManager = try await setup(with: container)
		
		workoutManager.startNewWorkout()
		guard let initialWorkoutId = workoutManager.currentWorkoutId else {
			return XCTFail("No workoutId found.")
		}
		
		let newWorkoutManager = try await setup(with: container)
		
		let currentWorkout = newWorkoutManager.currentWorkout
		let currentWorkoutId = newWorkoutManager.currentWorkoutId
		let savedWorkoutExists = FileManager.default.fileExists(atPath: savePath.path)
		
		let workoutRecordsInDB = try fetchModelCount(ofType: WorkoutRecord.self, in: container.mainContext)
		
		// Then: assert that the initial state is as expected
		XCTAssertNotNil(currentWorkout, "Expected current workout after starting a workout")
		XCTAssertNotNil(currentWorkoutId, "Expected current workout ID after starting a workout")
		XCTAssertTrue(savedWorkoutExists, "Expected saved workout file after starting a workout")
		XCTAssertEqual(workoutRecordsInDB, 1, "Expected 1 workout record in the database after starting a workout")
		XCTAssertEqual(initialWorkoutId, currentWorkoutId, "Expected the initial and current workoutId to be the same")
	}
	
	// Should cancel a workout correctly and clean up
	@MainActor
	func testCancelWorkout() async throws {
		let container = try await createContainer()
		let workoutManager = try await setup(with: container)
		
		workoutManager.startNewWorkout()
		workoutManager.cancel()
		
		let currentWorkout = workoutManager.currentWorkout
		let currentWorkoutId = workoutManager.currentWorkoutId
		let savedWorkoutExists = FileManager.default.fileExists(atPath: savePath.path)
		let workoutRecordsInDB = try fetchModelCount(ofType: WorkoutRecord.self, in: container.mainContext)
		
		XCTAssertNil(currentWorkout, "Expected no workout after canceling")
		XCTAssertNil(currentWorkoutId, "Expected no current workout ID after canceling")
		XCTAssertFalse(savedWorkoutExists, "Expected no saved workout file after canceling")
		XCTAssertEqual(workoutRecordsInDB, 0, "Expected no workout record in the database after after canceling")
	}
	
	// Should not restore a workout that's been cancelled
	@MainActor
	func testRestoreAfterCancelWorkout() async throws {
		let container = try await createContainer()
		let workoutManager = try await setup(with: container)
		
		workoutManager.startNewWorkout()
		workoutManager.cancel()
		
		let newWorkoutManager = try await setup(with: container)
		
		let currentWorkout = newWorkoutManager.currentWorkout
		let currentWorkoutId = newWorkoutManager.currentWorkoutId
		let savedWorkoutExists = FileManager.default.fileExists(atPath: savePath.path)
		
		let workoutRecordsInDB = try fetchModelCount(ofType: WorkoutRecord.self, in: container.mainContext)
		
		// Then: assert that the initial state is as expected
		XCTAssertNil(currentWorkout, "Expected no workout after canceling")
		XCTAssertNil(currentWorkoutId, "Expected no current workout ID after canceling")
		XCTAssertFalse(savedWorkoutExists, "Expected no saved workout file after canceling")
		XCTAssertEqual(workoutRecordsInDB, 0, "Expected no workout record in the database after after canceling")
	}
	
	// Should save a workout if completed with a valid set
	@MainActor
	func testCompleteValidWorkout() async throws {
		let container = try await createContainer()
		let workoutManager = try await setup(with: container)
		
		workoutManager.startNewWorkout()
		
		let exerciseRecord = ExerciseRecord()
		exerciseRecord.details = try getExerciseDetail(from: container.mainContext)
		
		exerciseRecord.sets.append(createValidSet())
		workoutManager.currentWorkout?.exercises.append(exerciseRecord)
		
		workoutManager.complete()
		
		let savedWorkoutExists = FileManager.default.fileExists(atPath: savePath.path)
		let workoutRecordsInDB = try fetchModelCount(ofType: WorkoutRecord.self, in: container.mainContext)
		let exerciseRecordsInDB = try fetchModelCount(ofType: ExerciseRecord.self, in: container.mainContext)
		
		// Then: assert that the initial state is as expected
		XCTAssertNil(workoutManager.currentWorkout, "Expected no workout after completing")
		XCTAssertNil(workoutManager.currentWorkoutId, "Expected no current workout ID after completing")
		XCTAssertFalse(savedWorkoutExists, "Expected no saved workout file after completing")
		XCTAssertEqual(workoutRecordsInDB, 1, "Expected 1 workout record in the database after after completing")
		XCTAssertEqual(exerciseRecordsInDB, 1, "Expected 1 exercise record in the database after after completing")
	}
	
	// Should not save a workout if completed without a valid set
	@MainActor
	func testCompleteInvalidWorkout() async throws {
		let container = try await createContainer()
		let workoutManager = try await setup(with: container)
		
		workoutManager.startNewWorkout()
		workoutManager.complete()
		
		let savedWorkoutExists = FileManager.default.fileExists(atPath: savePath.path)
		let descriptor = FetchDescriptor<WorkoutRecord>(predicate: #Predicate { _ in true })
		let workoutRecordsInDB = try container.mainContext.fetch(descriptor).count
		
		// Then: assert that the initial state is as expected
		XCTAssertNil(workoutManager.currentWorkout, "Expected no workout after completing")
		XCTAssertNil(workoutManager.currentWorkoutId, "Expected no current workout ID after completing")
		XCTAssertFalse(savedWorkoutExists, "Expected no saved workout file after completing")
		XCTAssertEqual(workoutRecordsInDB, 0, "Expected no workout records in the database after after completing")
	}
	
	// Should delete all valid exercises if workout is cancelled
	@MainActor
	func testCancelValidWorkout() async throws {
		let container = try await createContainer()
		let workoutManager = try await setup(with: container)
		
		workoutManager.startNewWorkout()
		
		let exerciseRecord = ExerciseRecord()
		exerciseRecord.details = try getExerciseDetail(from: container.mainContext)
		var set = SetRecord()
		set.reps = 5
		set.value = 50
		set.complete = true
		exerciseRecord.sets.append(set)
		workoutManager.currentWorkout?.exercises.append(exerciseRecord)
		
		workoutManager.cancel()
		
		let savedWorkoutExists = FileManager.default.fileExists(atPath: savePath.path)
		let descriptor = FetchDescriptor<WorkoutRecord>(predicate: #Predicate { _ in true })
		let workoutRecordsInDB = try workoutManager.modelContext.fetch(descriptor).count
		
		
		let descriptorExerciseRecord = FetchDescriptor<ExerciseRecord>(predicate: #Predicate { _ in true })
		let exerciseRecordsInDB = try workoutManager.modelContext.fetch(descriptorExerciseRecord).count
		
		// Then: assert that the initial state is as expected
		XCTAssertNil(workoutManager.currentWorkout, "Expected no workout after canceling")
		XCTAssertNil(workoutManager.currentWorkoutId, "Expected no current workout ID after canceling")
		XCTAssertFalse(savedWorkoutExists, "Expected no saved workout file after canceling")
		XCTAssertEqual(workoutRecordsInDB, 0, "Expected 0 workout records in the database after after canceling")
		XCTAssertEqual(exerciseRecordsInDB, 0, "Expected 0 exercise records in the database after after canceling")
	}
	
	// MARK: - Helper Functions
	@MainActor
	func createContainer() async throws -> ModelContainer {
		let config = ModelConfiguration(isStoredInMemoryOnly: true)
		let container = try ModelContainer(for: WorkoutRecord.self, configurations: config)
		
		func addDummyExercises(in modelContext: ModelContext) {
			let pullups = Exercise(name: "Pullups")
			let pushups = Exercise(name: "Pushups")
			
			modelContext.insert(pullups)
			modelContext.insert(pushups)
		}
		
		addDummyExercises(in: container.mainContext)
		
		return container
	}
	
	@MainActor
	func setup(with container: ModelContainer) async throws -> WorkoutManager {
		let workoutManager = WorkoutManager(modelContext: container.mainContext)
		return workoutManager
	}
	
	func getExerciseDetail(from modelContext: ModelContext) throws -> Exercise {
		let descriptor = FetchDescriptor<Exercise>(predicate: #Predicate { _ in true })
		let exercises = try modelContext.fetch(descriptor)
		let id = exercises.randomElement()!.id
		return modelContext.model(for: id) as? Exercise ?? Exercise(name: "AUTO_GENERATED")
	}
	
	func createValidSet() -> SetRecord {
		var set = SetRecord()
		set.reps = 5
		set.value = 50
		set.complete = true
		return set
	}
	
	func fetchModelCount<T: PersistentModel>(ofType type: T.Type, in context: ModelContext) throws -> Int {
		let descriptor = FetchDescriptor<T>(predicate: #Predicate { _ in true })
		return try context.fetch(descriptor).count
	}
}
