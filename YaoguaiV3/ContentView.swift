//
//  ContentView.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 7/7/2024.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
//    @Query private var items: [Item]

    var body: some View {
		Text("")
    }
}

#Preview {
    ContentView()
        .modelContainer(for: WorkoutRecord.self, inMemory: true)
}
