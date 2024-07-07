//
//  Record.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 7/7/2024.
//

import Foundation
import SwiftData

@Model final class Exercise {
	var name: String
	
	init(name: String) {
		self.name = name
	}
}

struct SetRecord: Identifiable, Codable, Equatable  {
	var id = UUID()
}

@Model final class ExerciseRecord {
	var workout: WorkoutRecord?
	var details: Exercise?
	var sets: [SetRecord] = []
	
	init() {}
}

@Model final class WorkoutRecord {
	var name: String
	
	@Relationship(deleteRule: .cascade, inverse: \ExerciseRecord.workout)
	var exercises: [ExerciseRecord] = []
	
	@Transient
	var isCurrentWorkout = false
	
	init(name: String = "") {
		self.name = name
	}
}
