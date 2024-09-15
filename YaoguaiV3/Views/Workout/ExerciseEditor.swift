//
//  ExerciseEditor.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 21/8/2024.
//

import SwiftUI

struct ExerciseEditor<T: ExerciseCommon>: View {
	@Bindable var exercise: T
	var delete: () -> Void
	
	init(exercise: T, delete: @escaping () -> Void) {
		self.exercise = exercise
		self.delete = delete
	}
	
	var body: some View {
		VStack(alignment: .leading) {
			HStack {
				Text(exercise.id.hashValue.formatted().prefix(7))
					.lineLimit(1)
					.padding(.horizontal)
					.background(.bar)
				Text(exercise.details?.name ?? "")
				Button("Delete", role: .destructive, action: delete)
				Spacer()
				Button("Add Set") {
					exercise.addSet()
				}
			}
			
			if exercise.sets.count > 0 {
				HStack {
					VStack {
						ForEach(Array($exercise.sets.enumerated()), id: \.1.id) { index, set in
							SetEditor(set: set, exercise: exercise.details, index: index, delete: { _ in
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
