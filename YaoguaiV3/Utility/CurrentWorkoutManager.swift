//
//  CurrentWorkoutManager.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 12/7/2024.
//

import Foundation
import SwiftData
import SwiftUI
import Observation

@Observable
final class CurrentWorkoutManager {
	var modelContext: ModelContext
	var currentWorkoutId: PersistentIdentifier? {
		didSet {
			save()
		}
	}
	var currentWorkout: WorkoutRecord? {
		didSet {
			self.currentWorkoutId = currentWorkout?.id
		}
	}
	var startTime: Date
	
	let savePath = URL.documentsDirectory.appending(path: "CurrentWorkout")
	
	@MainActor
	init(modelContext: ModelContext) {
		self.modelContext = modelContext
		self.startTime = Date()
		
		if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
			return
		}
		
		loadCurrentWorkout()
	}
	
	@MainActor
	func loadCurrentWorkout() {
		/// Need to early return if we're in preview otherwise I get FatalError "Failed to create a managed objectID"
		if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
			return
		}
		
		do {
			guard FileManager.default.fileExists(atPath: savePath.path) else {
				return
			}
			
			let data = try Data(contentsOf: savePath)
			let savedPersistentIdentifier = try JSONDecoder().decode(PersistentIdentifier.self, from: data)

			if let savedWorkout = modelContext.model(for: savedPersistentIdentifier) as? WorkoutRecord {
				modelContext.insert(savedWorkout)
				currentWorkout = savedWorkout
			
				track("Initialised current workout with saved workout")

			} else {
				track("No workout saved, won't initialise current workout")
			}
		} catch {
			track("Unable to load data. \(error.localizedDescription)")
		}
	}
	
	private func save() {
		if let currentWorkoutId {
			do {
				let data = try JSONEncoder().encode(currentWorkoutId)
				try data.write(to: savePath, options: [.atomic, .completeFileProtection])
			} catch {
				track("Unable to save current workout. \(error.localizedDescription)")
			}
		}
	}
	
	@MainActor
	func cancel() {
		if let currentWorkout {
			try? modelContext.transaction {
				modelContext.delete(currentWorkout)
				
				// Although these will be cascade deleted, it won't happen immediately, XCTest assertions fail
				currentWorkout.exercises.forEach { record in
					modelContext.delete(record)
				}
			}
		}
		
		self.currentWorkoutId = nil
		self.currentWorkout = nil
		
		do {
			try FileManager.default.removeItem(at: savePath)
		} catch {
			track("Unable to delete saved workout file. \(error.localizedDescription)")
		}
	}
	
	@MainActor
	func complete() {
		track("Completing workout")
		guard let currentExercises = currentWorkout?.exercises else { return }
		guard let currentWorkout else { return }
		
		/// For all exercises, filter out any sets that haven't been completed
		currentExercises.enumerated().forEach({ idx, exercise in
			currentExercises[idx].sets = currentExercises[idx].sets.filter({ setRecord in
				setRecord.complete
			})
		})
		
		/// Remember, transaction saves at the end of the closure
		try? modelContext.transaction {
			currentExercises.enumerated().forEach { idx, exercise in
				if exercise.sets.isEmpty {
					track("🗑️ Deleting an exercise record because it's empty")
					modelContext.delete(exercise)
				}
			}
		}
		
		/// Here we DON'T use currentExercises to check, as it's a constant.  We use the original array.
		/// Items will be auto removed when deleted from the context.
		track("Remaining exercise records: \(currentWorkout.exercises.count)")
		
		/// If there's 0 exercises remaining, don't save the workout
		if currentWorkout.exercises.count == 0 {
			modelContext.delete(currentWorkout)
		} else {
			/// Update the latest exercise records
			currentWorkout.exercises.forEach { record in
				record.details?.latestRecord = record
			}
		}
		
		self.currentWorkoutId = nil
		self.currentWorkout = nil
		
		do {
			try FileManager.default.removeItem(at: savePath)
			track("Removed workoutId from documents")
		} catch {
			track("Unable to delete saved workout file. \(error.localizedDescription)")
		}
	}
	
	@MainActor
	func startNewWorkout() {
		track("Starting new workout")
		
		let newWorkout = WorkoutRecord(name: "New Workout")
		modelContext.insert(newWorkout)
		
		/// Need to call save here to guarantee it's saved, otherwise, we could have an ID with no actual workout
		try? modelContext.save()
		
		/// Before I needed a Task is for visual bug when currentWorkout is used to display a sheet
		/// Forces code to run on next runloop, similar to process.nextTick
		currentWorkout = newWorkout
	}
	
}
