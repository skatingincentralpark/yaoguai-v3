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
	
	@Relationship(deleteRule: .cascade, inverse: \ExerciseRecord.details)
	var records: [ExerciseRecord] = []

	var latestRecord: ExerciseRecord?
	
	init(name: String) {
		self.name = name
	}
}

struct SetRecord: Identifiable, Codable, Equatable {
	var id = UUID()
	
	var value: Double? {
		didSet {
			if value == nil {
				_complete = false
			}
		}
	}
	var reps: Int? {
		didSet {
			if reps == nil {
				_complete = false
			}
		}
	}
	var rpe: Double? {
		didSet {
			if rpe == nil {
				_complete = false
			}
		}
	}
	
	private var _complete = false
	
	var complete: Bool {
		get {
			_complete
		}
		set {
			if value != nil && reps != nil {
				_complete = newValue
			}
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
	let created: Date = Date()
	var workout: WorkoutRecord?
	var details: Exercise?
	var sets: [SetRecord] = []
	
	init() {}
}

@Model final class WorkoutRecord {
	var name: String
	var created: Date = Date()
	
	@Relationship(deleteRule: .cascade, inverse: \ExerciseRecord.workout)
	var exercises: [ExerciseRecord] = []
	
	public var orderedExercises: [ExerciseRecord] {
		set(newExercises) {
			exercises = newExercises
		}
		get {
			exercises.sorted(by: { $0.created < $1.created })
		}
	}
	
	init(name: String = "") {
		self.name = name
	}
}
