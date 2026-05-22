//
//  TabbarView.swift
//  QR-Scanner-App
//
//  Created by Mehta, Utkarsh on 22/05/26.
//

import SwiftUI
import SwiftData

struct TabbarView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "house.fill") }

            HistoryView()
                .tabItem { Label("History", systemImage: "clock.arrow.circlepath") }
        }
        .tint(.primary)
    }
}

#Preview {
    TabbarView()
        .modelContainer(for: ScanRecord.self, inMemory: true)
}
