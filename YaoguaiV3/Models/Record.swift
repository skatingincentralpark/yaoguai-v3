//
//  Record.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 7/7/2024.
//

import Foundation
import SwiftData

@Model final class Exercise {
	@Attribute(.unique) var name: String
	
	init(name: String) {
		self.name = name
	}
}

struct SetRecord: Identifiable, Codable, Equatable  {
	var id = UUID()
	var value: Double?
	var reps: Int?
	var rpe: Double?
	private var _complete = false
	
	var complete: Bool {
		get {
			_complete
		}
		set {
			_complete = newValue
		}
	}
	
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
	
@Model final class ExerciseRecord {
	let timestamp: Date = Date()
	var workout: WorkoutRecord?
	var details: Exercise?
	var sets: [SetRecord] = []
	
	init() {}
}

@Model final class WorkoutRecord {
	var name: String
	
	@Relationship(deleteRule: .cascade, inverse: \ExerciseRecord.workout)
	var exercises: [ExerciseRecord] = []
	
	public var orderedExercises: [ExerciseRecord] {
		set(newExercises) {
			exercises = newExercises
		}
		get {
			exercises.sorted(by: { $0.timestamp < $1.timestamp })
		}
	}
	
	init(name: String = "") {
		self.name = name
	}
}
