//
//  WorkoutManager.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 12/7/2024.
//

import Foundation
import SwiftData
import SwiftUI
import Observation

@Observable
final class WorkoutManager {
	var modelContext: ModelContext
	private var currentWorkoutId: PersistentIdentifier? {
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
	
	func loadCurrentWorkout() {
		// Need to early return if we're in preview otherwise I get FatalError "Failed to create a managed objectID"
		if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
			return
		}
		
		do {
			let data = try Data(contentsOf: savePath)
			let savedPersistentIdentifier = try JSONDecoder().decode(PersistentIdentifier.self, from: data)
			print(savedPersistentIdentifier)
			
			if let savedWorkout = modelContext.model(for: savedPersistentIdentifier) as? WorkoutRecord {
				modelContext.insert(savedWorkout)
				currentWorkout = savedWorkout
				
				print("Initialised current workout with saved workout")
			} else {
				print("No workout saved, won't initialise current workout.")
			}
		} catch {
			print("Unable to load data.  \(error.localizedDescription)")
		}
	}
	
	private func save() {
		Task(priority: .background) {
			do {
				let data = try JSONEncoder().encode(currentWorkoutId)
				try data.write(to: savePath, options: [.atomic, .completeFileProtection])
			} catch {
				print("Unable to save current workout.  \(error.localizedDescription)")
			}
		}
	}
	
	@MainActor
	func cancel() {
		if let currentWorkout {
			modelContext.delete(currentWorkout)
		}
		
		self.currentWorkoutId = nil
		self.currentWorkout = nil
		
		Task(priority: .background) {
			do {
				try FileManager.default.removeItem(at: savePath)
				print("Deleted workout.")
			} catch {
				print("Unable to delete saved workout file.  \(error.localizedDescription)")
			}
		}
	}
	
	@MainActor
	func complete() {
		if let currentWorkout {
			modelContext.insert(currentWorkout)
		}
		
		self.currentWorkoutId = nil
		self.currentWorkout = nil
		
		Task(priority: .background) {
			do {
				try FileManager.default.removeItem(at: savePath)
				print("Removed workoutId from documents.")
			} catch {
				print("Unable to delete saved workout file.  \(error.localizedDescription)")
			}
		}
	}
	
	@MainActor
	func startNewWorkout() {
		print("Starting workout.")
		
		let newWorkout = WorkoutRecord(name: "New Workout")
		modelContext.insert(newWorkout)
		
		// Need to call save here to guarantee it's saved, otherwise, we could have an ID with no actual workout
		try? modelContext.save()
		
		// Task is for visual bug when currentWorkout is used to display a sheet
		// Forces code to run on next runloop, similar to process.nextTick
		Task { currentWorkout = newWorkout }
	}
	
}
