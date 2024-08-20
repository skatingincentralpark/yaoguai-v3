import SwiftUI

struct NumericKeyboardView: View {
	var insertText: (String) -> Void
	var deleteText: () -> Void
	var hideKeyboard: () -> Void
	
	let keyboardHeight: CGFloat
	var backgroundColor: Color
	
	private let numberList = [
		"1", "4", "7",
		".", "2", "5",
		"8", "0", "3",
		"6", "9"
	]
	 
	let rows: [GridItem] = [
		.init(.flexible(minimum: 0, maximum: .infinity), spacing: 0),
		.init(.flexible(minimum: 0, maximum: .infinity), spacing: 0),
		.init(.flexible(minimum: 0, maximum: .infinity), spacing: 0),
		.init(.flexible(minimum: 0, maximum: .infinity), spacing: 0),
	]
	
	var body: some View {
		LazyHGrid(rows: rows, alignment: .top, spacing: 0, content: {
			
			ForEach(numberList, id: \.self) { number in
				Button(action: {
					insertText(number)
				}, label: {
					Text(number)
						.font(.system(size: 32))
						.frame(maxHeight: .infinity)
						.containerRelativeFrame(.horizontal, count: 4, spacing: 0)
						.background(.white)
				})
			}
			
			Button(action: deleteText, label: {
				Image(systemName: "delete.backward")
			})
			.frame(maxHeight: .infinity)
			.containerRelativeFrame(.horizontal, count: 4, spacing: 0)
			.background(.white)
			
			Button(action: hideKeyboard, label: {
				Image(systemName: "keyboard.chevron.compact.down")
					.frame(maxHeight: .infinity)
					.containerRelativeFrame(.horizontal, count: 4, spacing: 0)
					.background(.white)
			})
	
			Button("RPE") {}
				.frame(maxHeight: .infinity)
				.containerRelativeFrame(.horizontal, count: 4, spacing: 0)
				.background(.white)
			
			HStack(spacing: 0 ) {
				Button(action: {}, label: {
					Image(systemName: "minus")
						.frame(maxWidth: .infinity, maxHeight: .infinity)
						.background(.white)
				})
				
				Button(action: {}, label: {
					Image(systemName: "plus")
						.frame(maxWidth: .infinity, maxHeight: .infinity)
						.background(.white)
				})
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.containerRelativeFrame(.horizontal, count: 4, spacing: 0)
			
			Button("Next") {}
				.frame(maxWidth: .infinity, maxHeight: .infinity)
				.containerRelativeFrame(.horizontal, count: 4, spacing: 0)
				.background(.white)
		})
		.padding(.top, 32)
		.padding(.bottom, 16)
		.frame(height: keyboardHeight)
		.frame(maxWidth: .infinity)
		.background(backgroundColor)
	}
}

#Preview(traits: .sizeThatFitsLayout) {
	NumericKeyboardView(
		insertText: { _ in },
		deleteText: { },
		hideKeyboard: { },
		keyboardHeight: 300,
		backgroundColor: Color.gray
	)
}
