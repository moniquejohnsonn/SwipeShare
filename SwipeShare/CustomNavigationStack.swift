//
//  CustomNavigationStack.swift
//  SwipeShare
//
//  Created by Adira Sklar on 11/21/24.
//

import SwiftUI

struct NoBackButtonNavigationStack<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        NavigationStack {
            content
                .navigationBarBackButtonHidden(true) // Globally applies to all views
        }
    }
}
