//
//  Exercise.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 13/9/2024.
//

import Foundation
import SwiftData

@Model final class Exercise {
	@Attribute(.unique) var name: String
	
	@Relationship(deleteRule: .cascade, inverse: \ExerciseRecord.details)
	var records: [ExerciseRecord] = []

	var latestRecord: ExerciseRecord?
	var category: ExerciseCategory
	
	init(name: String, category: ExerciseCategory) {
		self.name = name
		self.category = category
	}
}
