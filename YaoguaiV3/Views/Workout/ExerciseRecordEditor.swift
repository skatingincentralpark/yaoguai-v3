//
//  ExerciseRecordEditor.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 21/8/2024.
//

import SwiftUI

struct ExerciseRecordEditor: View {
	@Bindable var exercise: ExerciseRecord
	var delete: () -> Void
	
	init(exercise: ExerciseRecord, delete: @escaping () -> Void) {
		self.exercise = exercise
		self.delete = delete
		//		print("Initialising ExerciseRecordEditor")
	}
	
	var body: some View {
		VStack(alignment: .leading) {
			HStack {
				Text(exercise.id.hashValue.formatted().prefix(7))
					.lineLimit(1)
					.padding(.horizontal)
					.background(.bar)
				Text(exercise.details?.name ?? "")
				Button("Delete", action: delete)
			}
			
			Button("Add Set") {
				exercise.sets.append(SetRecord())
			}
			
			Button("Get Last Exercise Record") {
				print("==========")
				if let latest = exercise.details?.latestRecord {
					print("value: \(latest.sets.first?.valueString)")
					print("reps: \(latest.sets.first?.repsString)")
					print("rpe: \(latest.sets.first?.rpeString)")
				} else {
					print("Nil!")
				}
			}
			
			if exercise.sets.count > 0 {
				HStack {
					VStack {
						ForEach($exercise.sets) { set in
							SetRecordEditor(set: set, delete: { _ in
								if let index = exercise.sets.firstIndex(where: { $0 == set.wrappedValue }) {
									exercise.sets.remove(at: index)
								}
							})
							.padding(.leading)
						}
						
						
					}
					.overlay(alignment: .leading) {
						Rectangle()
							.frame(width: 1)
					}
				}
				.padding(.leading)
			}
		}
	}
}
