//
//  Template.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 11/9/2024.
//

import Foundation
import SwiftData

struct SetTemplate: SetCommon {
	var id = UUID()
	var category: ExerciseCategory = ExerciseCategory.weightAndReps
	
	// Properties for weighted exercises
	var value: Measurement<UnitMass>?
	var reps: Int?
	var rpe: Double?
	
	// Properties for duration-based exercises
	var duration: TimeInterval?

	// Properties for cardio/distance-based exercises
	var distance: Measurement<UnitLength>?
}

@Model final class ExerciseTemplate: ExerciseCommon {
	var created: Date = Date()
	var details: Exercise?
	var workout: WorkoutTemplate?
	var sets: [SetTemplate] = []
	
	init() {}
}

@Model final class WorkoutTemplate: WorkoutCommon {
	var name: String = ""
	var created: Date = Date()
	@Relationship(deleteRule: .cascade, inverse: \ExerciseTemplate.workout)
	var exercises: [ExerciseTemplate] = []
	
	init() {}
}
