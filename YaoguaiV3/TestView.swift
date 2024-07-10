//
//  TestView.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 8/7/2024.
//

import SwiftUI
import SwiftData

@Model
final class Item {
	var timestamp: Int
	@Relationship(deleteRule: .cascade, inverse: \Tag.item)
	var tags: Array<Tag> = []
	
	init(timestamp: Int) {
		self.timestamp = timestamp
	}
}

@Model
final class Tag {
	var name: String
	var item: Item?
	
	init(name: String) {
		self.name = name
	}
}

struct TestView: View {
	@Environment(\.modelContext) private var context
	@Query var items: [Item]
	@Query var tags: [Tag]
	
    var body: some View {
		Text("Item Count: \(items.count)")
		Text("Tags Count: \(tags.count)")
        Text("Hello, World!")
			.onAppear {
				print("Hey")
				
				// Create One Item and One Hundred Tags
				let item = Item(timestamp: 100)
				context.insert(item)
				for i in 0..<100 {
					let tag = Tag(name: "\(i)")
					item.tags.append(tag)
				}
				try? context.save()

				
				print("Bye")
			}
    }
}

#Preview {
    TestView()
		.modelContainer(for: Item.self, inMemory: true)
}
