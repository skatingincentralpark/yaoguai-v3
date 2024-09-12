//
//  Protocols.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 11/9/2024.
//

import Foundation

protocol WorkoutCommon {
	associatedtype ExerciseType: ExerciseCommon
	
	var name: String { get set }
	var created: Date { get set }
	var exercises: [ExerciseType] { get set }
}

extension WorkoutCommon {
	var orderedExercises: [ExerciseType] {
		exercises.sorted(by: { $0.created < $1.created })
	}
}

protocol ExerciseCommon {
	associatedtype WorkoutType: WorkoutCommon
	associatedtype SetType: SetCommon
	
	var created: Date { get set }
	var details: Exercise? { get set }
	var workout: (WorkoutType)? { get set }
	var sets: [SetType] { get set }
}

protocol SetCommon: Identifiable, Codable, Equatable {
	var id: UUID { get set }
	var value: Double? { get set }
	var reps: Int? { get set }
	var rpe: Double? { get set }
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
