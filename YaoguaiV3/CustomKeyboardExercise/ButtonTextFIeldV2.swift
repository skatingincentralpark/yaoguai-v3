//
//  ButtonTextFIeldV2.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 13/8/2024.
//

import SwiftUI

struct ButtonTextFieldTestV2: View {
	@FocusState var focused
	@State private var input = ""
	
	var body: some View {
		SimpleTextFieldV2(id: UUID().hashValue, input: $input, keyboardHeight: 300)
			.focused($focused)
			.frame(height: 30)
			.background(.yellow)
			.clipShape(RoundedRectangle(cornerRadius: 6))
			.overlay {
				RoundedRectangle(cornerRadius: 6)
					.stroke(focused ? .green : .gray, lineWidth: 3.0)
			}
	}
}

class PaddedTextField: UITextField {
	var textPadding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
	
	override func textRect(forBounds bounds: CGRect) -> CGRect {
		return bounds.inset(by: textPadding)
	}
	
	override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
		return bounds.inset(by: textPadding)
	}
	
	override func editingRect(forBounds bounds: CGRect) -> CGRect {
		return bounds.inset(by: textPadding)
	}
}

struct SimpleTextFieldV2: UIViewRepresentable {
	var id: Int
	@Binding var input: String
	var keyboardHeight: CGFloat
	
	func makeUIView(context: Context) -> UIView {
		let textField = PaddedTextField()
		textField.layer.cornerRadius = 8.0
		textField.translatesAutoresizingMaskIntoConstraints = false
		textField.tag = id
		textField.text = input
		
		let button = UIButton(type: .system)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.layer.opacity = 0.2
		button.addTarget(context.coordinator, action: #selector(Coordinator.buttonTapped), for: .touchUpInside)
		button.tag = id
		
		let containerView = UIView()
		containerView.addSubview(textField)
		containerView.addSubview(button)
		
		func setupKeyboard() {
			let inputView = UIInputView()
			
			let AnimalKeyboardViewController = UIHostingController(
				rootView: NumericKeyboardView(
					insertText: { text in
						if let selectedTextRange = textField.selectedTextRange {
							textField.replace(selectedTextRange, withText: text)
						}
					},
					deleteText: textField.deleteBackward,
					hideKeyboard: { textField.endEditing(true) },
					keyboardHeight: keyboardHeight,
					backgroundColor: .white
				))
			
			let animalKeyboardView = AnimalKeyboardViewController.view!
			animalKeyboardView.translatesAutoresizingMaskIntoConstraints = false
			
			inputView.frame = CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: keyboardHeight))
			inputView.addSubview(animalKeyboardView)
			
			NSLayoutConstraint.activate([
				animalKeyboardView.widthAnchor.constraint(equalToConstant: inputView.frame.width)
			])
			
			textField.inputView = inputView
		}
		
		setupKeyboard()
		
		NSLayoutConstraint.activate([
			// Text field constraints
			textField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
			textField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
			textField.topAnchor.constraint(equalTo: containerView.topAnchor),
			textField.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
			
			// Button constraints
			button.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
			button.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
			button.topAnchor.constraint(equalTo: textField.topAnchor),
			button.bottomAnchor.constraint(equalTo: textField.bottomAnchor),
		])
		
		return containerView
	}
	
	func updateUIView(_ uiView: UIView, context: Context) {
		// No update needed
	}
	
	func makeCoordinator() -> Coordinator {
		Coordinator()
	}
	
	class Coordinator: NSObject {
		@objc func buttonTapped(_ sender: UIButton) {
			guard let containerView = sender.superview,
				  let textField = containerView.subviews.first(where: { $0 is UITextField && $0.tag == sender.tag }) as? UITextField else {
					  return
				  }
			
			// Focuses and selects all
			textField.becomeFirstResponder()
			textField.selectAll(nil)
		}
	}
}

struct ButtonTextFieldV2Preview: View {
	var body: some View {
		ScrollView {
			VStack(spacing: 10) {
				ForEach(0...10, id: \.self) { i in
					HStack(spacing: 10) {
						ButtonTextFieldTestV2()
						ButtonTextFieldTestV2()
						ButtonTextFieldTestV2()
					}
				}
			}
			.padding()
		}
	}
}

#Preview {
	ButtonTextFieldV2Preview()
}
