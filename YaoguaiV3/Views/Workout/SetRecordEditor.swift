//
//  SetRecordEditor.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 21/8/2024.
//

import SwiftUI

struct SetRecordEditor: View {
	@Binding var set: SetRecord
	
	var delete: (SetRecord) -> Void
	
	@FocusState private var valueFocused: Bool
	@FocusState private var repsFocused: Bool
	@FocusState private var rpeFocused: Bool
	
	var body: some View {
		HStack {
			SimpleTextFieldV2(
				id: UUID().hashValue,
				input: Binding(
					get: {
						set.valueString
					},
					set: { newValue in
						set.value = Double(newValue)
					}
				),
				keyboardHeight: 300)
			.focused($valueFocused)
			.frame(height: 30)
			.background(.yellow)
			.clipShape(RoundedRectangle(cornerRadius: 6))
			.overlay {
				RoundedRectangle(cornerRadius: 6)
					.stroke(valueFocused ? .green : .gray, lineWidth: 3.0)
			}
			
			SimpleTextFieldV2(
				id: UUID().hashValue,
				input: Binding(
					get: {
						set.repsString
					},
					set: { newValue in
						set.reps = Int(newValue)
					}
				),
				keyboardHeight: 300)
			.focused($repsFocused)
			.frame(height: 30)
			.background(.yellow)
			.clipShape(RoundedRectangle(cornerRadius: 6))
			.overlay {
				RoundedRectangle(cornerRadius: 6)
					.stroke(repsFocused ? .green : .gray, lineWidth: 3.0)
			}
			
			SimpleTextFieldV2(
				id: UUID().hashValue,
				input: Binding(
					get: {
						set.rpeString
					},
					set: { newValue in
						set.rpe = Double(newValue)
					}
				),
				keyboardHeight: 300)
			.focused($rpeFocused)
			.frame(height: 30)
			.background(.yellow)
			.clipShape(RoundedRectangle(cornerRadius: 6))
			.overlay {
				RoundedRectangle(cornerRadius: 6)
					.stroke(rpeFocused ? .green : .gray, lineWidth: 3.0)
			}
			
			Button(role: .destructive) {
				delete(set)
			} label: {
				Image(systemName: "xmark")
			}
			.buttonStyle(.bordered)
			.tint(.red)
			
			Toggle(isOn: $set.complete) {
				Image(systemName: "checkmark")
			}
			.toggleStyle(.button)
			.buttonStyle(.bordered)
			.tint(set.complete ? .green : .black)
			
		}
	}
}
