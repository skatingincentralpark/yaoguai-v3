//
//  PreviewSetup.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 16/9/2024.
//

import Foundation
import SwiftData

@MainActor
func setupPreview() throws -> (ModelContainer, WorkoutManager) {
	let modelContainer: ModelContainer
	modelContainer = try ModelContainer(for: WorkoutRecord.self, WorkoutTemplate.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
	
	let record = getWorkoutRecord(modelContainer.mainContext)
	modelContainer.mainContext.insert(record)
		
	let workoutManager = WorkoutManager(modelContext: modelContainer.mainContext)
	
	return (modelContainer, workoutManager)
}

func getWorkoutRecord(_ context: ModelContext) -> WorkoutRecord {
	let pullups = Exercise(name: "Pullups")
	let pushups = Exercise(name: "Pushups")
	context.insert(pullups)
	context.insert(pushups)
	
	let record1 = WorkoutRecord(name: "Upper")
	let exercise1 = ExerciseRecord()
	let exercise2 = ExerciseRecord()
	context.insert(exercise1)
	context.insert(exercise2)
	exercise1.details = pullups
	exercise2.details = pushups
	record1.exercises = [exercise1, exercise2]
	
	record1.exercises.first?.addSet()
	
	return record1
}
