//
//  AppSpecificKeyboardDemo.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 20/7/2024.
//

import SwiftUI



/// Code to set the inputView property of text fields or text views to a view that should replace the system keyboard!
struct AppSpecificKeyboardDemo: View {
	@State private var input: String = ""
	@FocusState private var inputFocused
	
	@State private var textFieldRect: CGRect = .zero
	private let keyboardHeight: CGFloat = 300.0
	
	private let cornerRadius = 6.0
	
	var body: some View {
		VStack {
			WorkoutTextField(input: $input, keyboardHeight: keyboardHeight)
				.frame(height: 100) // Adjusted height to accommodate both text field and button
				.focused($inputFocused)
				.background(
					RoundedRectangle(cornerRadius: cornerRadius)
						.fill(.gray.opacity(0.1))
				)
				.overlay {
					RoundedRectangle(cornerRadius: cornerRadius)
						.stroke(.green, lineWidth: 2.0)
						.opacity(inputFocused ? 1 : 0)
						.animation(.easeInOut(duration: 0.5), value: inputFocused)
				}
				.overlay(content: {
					GeometryReader { geometry in
						DispatchQueue.main.async {
							self.textFieldRect = geometry.frame(in: .global)
						}
						return Color.clear
					}
				})
		}
		.frame(maxWidth: .infinity, alignment: .center)
		.contentShape(Rectangle())
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
	
	func makeUIView(context: Context) -> UIView {
		let containerView = UIView()
		
		let textField = UITextField()
		textField.text = input
		textField.delegate = context.coordinator
		textField.textAlignment = .center
		
		// required so that the textfield height is not filling up the entire screen
		textField.setContentHuggingPriority(.defaultHigh, for: .vertical)
		textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
		
		let AnimalKeyboardViewController = UIHostingController(
			rootView: NumericKeyboardView(
				insertText: { text in
					// check if cursor isn't at end
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
			animalKeyboardView.widthAnchor.constraint(equalToConstant: inputView.frame.width)
		])
		
		textField.inputView = inputView
		
		// Add the button beneath the text field
		let button = UIButton(type: .custom)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.backgroundColor = UIColor.red.withAlphaComponent(0.3) // Make button visible
		button.setTitle("Select All", for: .normal)
		button.addTarget(context.coordinator, action: #selector(Coordinator.selectAllText(sender:)), for: .touchUpInside)
		
		containerView.addSubview(textField)
		containerView.addSubview(button)
		
	
		NSLayoutConstraint.activate([
			// Text field constraints
			textField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
			textField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
			textField.topAnchor.constraint(equalTo: containerView.topAnchor),
			
			// Button constraints
			button.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
			button.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
			button.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 10),
			button.heightAnchor.constraint(equalToConstant: 44),
			button.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
		])
		
		return containerView
	}
	
	func updateUIView(_ uiView: UIView, context: Context) {
		if let textField = uiView.subviews.first(where: { $0 is UITextField }) as? UITextField {
			textField.text = input
			textField.setContentHuggingPriority(.defaultHigh, for: .vertical)
			textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
		}
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
		
		// This prevents the edit menu from appearing
		func textField(_ textField: UITextField, editMenuForCharactersIn range: NSRange, suggestedActions: [UIMenuElement]) -> UIMenu? {
			return UIMenu()
		}
		
		func textFieldDidChangeSelection(_ textField: UITextField) {
			guard let text = textField.text else { return }
			parent.input = text
		}
		
		func textFieldDidBeginEditing(_ textField: UITextField) {
			//			print("Hello")
			//			textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
			textField.selectAll(nil)
		}
		
		func textFieldShouldReturn(_ textField: UITextField) -> Bool {
			textField.resignFirstResponder()
			return true
		}
		
		//		func textFieldDidEndEditing(_ textField: UITextField) {
		//		}
		
		@objc func selectAllText(sender: UIButton) {
			guard let textField = sender.superview as? UITextField else { return }
			textField.selectAll(nil)
			textField.becomeFirstResponder() // Focus the text field to bring up the keyboard
			print("Button tapped, all text selected, and keyboard shown.")
		}
	}
}

#Preview {
	VStack(spacing: 10) {
		HStack(spacing: 10) {
			AppSpecificKeyboardDemo()
			AppSpecificKeyboardDemo()
			AppSpecificKeyboardDemo()
		}
		HStack(spacing: 10) {
			AppSpecificKeyboardDemo()
			AppSpecificKeyboardDemo()
			AppSpecificKeyboardDemo()
		}
	}
	.padding()
}
