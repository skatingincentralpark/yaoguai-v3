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
	
	init(name: String) {
		self.name = name
	}
}
