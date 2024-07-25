//
//  AppSpecificKeyboardDemo.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 20/7/2024.
//

import SwiftUI



/// Code to set the inputView property of text fields or text views to a view that should replace the system keyboard!
struct AppSpecificKeyboardDemo: View {
	@State private var input: String = "➤➤"
	@FocusState private var inputFocused
	
	@State private var textFieldRect: CGRect = .zero
	private let keyboardHeight: CGFloat = 300.0
	
	var body: some View {
		VStack(spacing: 20) {
			Text("input: \(input)")
				.padding(.horizontal, 16)
			
			WorkoutTextField(input: $input, keyboardHeight: keyboardHeight)
				.focused($inputFocused)
				.background(
					RoundedRectangle(cornerRadius: 16)
						.fill(.yellow.opacity(0.3))
				)
				.overlay {
					RoundedRectangle(cornerRadius: 16)
						.stroke(.green, lineWidth: inputFocused ? 1.0 : 0)
				}
				.padding(16)
				.overlay(content: {
					GeometryReader { geometry in
						DispatchQueue.main.async {
							self.textFieldRect = geometry.frame(in: .global)
						}
						return Color.clear
					}
				})
				.padding()
			
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
		.contentShape(Rectangle())
		.onAppear {
			inputFocused = true
		}
		.onTapGesture(coordinateSpace: .global) { location in
			if !textFieldRect.contains(location) {
				inputFocused = false
			}
		}
		
	}
}

fileprivate struct WorkoutTextField: UIViewRepresentable {
	
	@Binding var input: String
	var keyboardHeight: CGFloat
	
	func makeUIView(context: Context) -> UITextField {
		let textField = UITextField()
		
		textField.text = input
		textField.font = .systemFont(ofSize: 12)
		textField.delegate = context.coordinator
		textField.tintColor = UIColor.red
		
		// required so that the textfield height is not filling up the entire screen
		textField.setContentHuggingPriority(.defaultHigh, for: .vertical)
		textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
		
		let AnimalKeyboardViewController = UIHostingController(
			rootView: NumericKeyboardView(
				insertText: { text in
					textField.text = "\(textField.text ?? "")\(text)"
				},
				deleteText: textField.deleteBackward,
				keyboardHeight: keyboardHeight,
				backgroundColor: .orange
			))
		
		let animalKeyboardView = AnimalKeyboardViewController.view!
		animalKeyboardView.translatesAutoresizingMaskIntoConstraints = false
		
		let inputView = UIInputView()
		inputView.frame = CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: keyboardHeight))
		
		inputView.addSubview(animalKeyboardView)
		
		NSLayoutConstraint.activate([
			//			animalKeyboardView.bottomAnchor.constraint(equalTo: inputView.bottomAnchor),
			animalKeyboardView.widthAnchor.constraint(equalToConstant: inputView.frame.width)
		])
		
		textField.inputView = inputView
		
		return textField
	}
	
	func updateUIView(_ uiView: UITextField, context: Context) {
		// required so that the textfield height is not filling up the entire screen
		uiView.setContentHuggingPriority(.defaultHigh, for: .vertical)
		uiView.setContentHuggingPriority(.defaultLow, for: .horizontal)
	}
}

fileprivate extension WorkoutTextField {
	
	func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}
	
	class Coordinator: NSObject, UITextFieldDelegate {
		var parent: WorkoutTextField
		
		init(_ control: WorkoutTextField) {
			self.parent = control
			super.init()
		}
		
		func textFieldDidChangeSelection(_ textField: UITextField) {
			guard let text = textField.text else { return }
			parent.input = text
		}
		
		func textFieldDidBeginEditing(_ textField: UITextField) {
			DispatchQueue.main.async {
				print("Did begin edit")
				textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
			}
		}
		
		func textFieldShouldReturn(_ textField: UITextField) -> Bool {
			textField.resignFirstResponder()
			return true
		}
		
	}
}
