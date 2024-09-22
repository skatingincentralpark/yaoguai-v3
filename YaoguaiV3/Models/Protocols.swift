//
//  Protocols.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 11/9/2024.
//

import Foundation
import Observation
import SwiftData

protocol WorkoutCommon: Observable, AnyObject, Identifiable, PersistentModel {
	associatedtype ExerciseType: ExerciseCommon
	
	var name: String { get set }
	var created: Date { get set }
	var exercises: [ExerciseType] { get set }
	
	init()
	
	func addExercise(with details: Exercise)
	func removeExercise(_ exercise: ExerciseType)
}

extension WorkoutCommon {
	func addExercise(with details: Exercise) {
		let exercise = ExerciseType()
		exercise.details = details
		exercises.append(exercise)
	}
	
	func removeExercise(_ exercise: ExerciseType) {
		exercises.removeFirst { $0 == exercise }
	}
	
	var orderedExercises: [ExerciseType] {
		exercises.sorted(by: { $0.created < $1.created })
	}
}

enum ExerciseCategory: String, Codable {
	case weightAndReps
	case reps
	case duration
	case durationAndWeight
	case distanceAndWeight
	case weightAndDistance
}

protocol ExerciseCommon: Observable, AnyObject, Identifiable, PersistentModel {
	associatedtype WorkoutType: WorkoutCommon
	associatedtype SetType: SetCommon
	
	var created: Date { get set }
	var details: Exercise? { get set }
	var workout: (WorkoutType)? { get set }
	var sets: [SetType] { get set }
	
	func addSet()
	func removeSet(_ set: SetType)
	
	init()
}

extension ExerciseCommon {
	func addSet() {
		if let category = details?.category {
			sets.append(SetType(category: category))
		}
	}
	
	func removeSet(_ set: SetType) {
		if let index = sets.firstIndex(where: { $0 == set }) {
			sets.remove(at: index)
		}
	}
}

protocol SetCommon: Identifiable, Codable, Equatable {
	var id: UUID { get set }
	var category: ExerciseCategory { get set }

	// Properties for weighted exercises
	var value: Measurement<UnitMass>? { get set }
	var reps: Int? { get set }
	var rpe: Double? { get set }
	
	// Properties for duration-based exercises
	var duration: TimeInterval? { get set } // Duration in seconds

	// Properties for cardio/distance-based exercises
	var distance: Measurement<UnitLength>? { get set } // Distance in kilometers or meters
	
	init(category: ExerciseCategory)
}

extension SetCommon {
	init(category: ExerciseCategory) {
		self.init(category: category)
		self.id = UUID()
	}
	
	var valueString: String {
		guard let value = value else { return "" }
		return value.formatted()
	}
	
	var rpeString: String {
		guard let rpe = rpe else { return "" }
		return String(rpe)
	}
	
	var repsString: String {
		guard let reps = reps else { return "" }
		return String(reps)
	}
}
