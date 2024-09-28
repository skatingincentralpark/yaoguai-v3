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

enum ExerciseCategory: String, Codable, CaseIterable {
	case weightAndReps
	case reps
	case duration
	case durationAndWeight
	case distanceAndWeight
	
	var title: String {
		switch self {
		case .weightAndReps:
			return "Weight and Reps"
		case .reps:
			return "Reps"
		case .duration:
			return "Duration"
		case .durationAndWeight:
			return "Duration and Weight"
		case .distanceAndWeight:
			return "Distance and Weight"
		}
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

	var value: Measurement<UnitMass>? { get set }
	var reps: Int? { get set }
	var rpe: Double? { get set }
	var duration: TimeInterval? { get set }
	var distance: Measurement<UnitLength>? { get set }
	
	init(category: ExerciseCategory)
}

extension SetCommon {
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
	
	var durationString: String {
		guard let duration = duration else { return "" }
		let seconds = Duration.seconds(duration)
		return seconds.formatted(.time(pattern: .minuteSecond))
	}
	
	var distanceString: String {
		guard let distance = distance else { return "" }
		return distance.formatted()
	}
}
