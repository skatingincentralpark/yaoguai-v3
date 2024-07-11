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
	let savePath = URL.documentsDirectory.appending(path: "CurrentWorkout")
	
	init(modelContext: ModelContext) {
		self.modelContext = modelContext
		
		do {
			let data = try Data(contentsOf: savePath)
			let savedPersistentIdentifier = try JSONDecoder().decode(PersistentIdentifier.self, from: data)
			currentWorkout = modelContext.model(for: savedPersistentIdentifier) as? WorkoutRecord ?? WorkoutRecord()
		} catch {
			print("Unable to initialise.")
		}
	}
	
	private func loadCurrentWorkout() {
		Task(priority: .background) {
			do {
				let data = try Data(contentsOf: savePath)
				let savedPersistentIdentifier = try JSONDecoder().decode(PersistentIdentifier.self, from: data)
				currentWorkout = modelContext.model(for: savedPersistentIdentifier) as? WorkoutRecord ?? WorkoutRecord()
			} catch {
				print("Unable to load data.")
			}
		}
	}
	
	private func save() {
		Task(priority: .background) {
			do {
				let data = try JSONEncoder().encode(currentWorkoutId)
				try data.write(to: savePath, options: [.atomic, .completeFileProtection])
			} catch {
				print("Unable to save dasta.")
			}
		}
	}
	
	func cancel() {
		guard let currentWorkout else { return }
		
		modelContext.delete(currentWorkout)
		self.currentWorkout = nil
		self.currentWorkoutId = nil
		
		Task(priority: .background) {
			do {
				try FileManager.default.removeItem(at: savePath)
			} catch {
				print("Unable to delete saved workout file.")
			}
		}
	}
	
	func startNewWorkout() {
		let newWorkout = WorkoutRecord()
		modelContext.insert(newWorkout)
		
		// Task is for visual bug when currentWorkout is used to display a sheet
		// Forces code to run on next runloop, similar to process.nextTick
		Task { currentWorkout = newWorkout }
	}
}
