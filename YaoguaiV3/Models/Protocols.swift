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
		sets.append(SetType())
	}
	
	func removeSet(_ set: SetType) {
		if let index = sets.firstIndex(where: { $0 == set }) {
			sets.remove(at: index)
		}
	}
}

protocol SetCommon: Identifiable, Codable, Equatable {
	var id: UUID { get set }
	var value: Double? { get set }
	var reps: Int? { get set }
	var rpe: Double? { get set }
	
	init()
}

extension SetCommon {
	var valueString: String {
		guard let value = value else { return "" }
		return String(value)
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
