//
//  Record.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 7/7/2024.
//

import Foundation
import SwiftData

struct SetRecord: SetCommon {
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
}
	
@Model final class ExerciseRecord: ExerciseCommon {
	var created: Date = Date()
	var details: Exercise?
	var workout: WorkoutRecord?
	var sets: [SetRecord] = []
	
	init() {}
}

@Model final class WorkoutRecord: WorkoutCommon {
	var name: String
	var created: Date = Date()
	
	@Relationship(deleteRule: .cascade, inverse: \ExerciseRecord.workout)
	var exercises: [ExerciseRecord] = []
	
	init(name: String = "") {
		self.name = name
	}
}
