//
//  headerView.swift
//  SwipeShare
//
//  Created by Rosa Figueroa on 11/14/24.
//
import SwiftUI

struct HeaderView: View {
    var title: String
    var showBackButton: Bool
    var onHeaderButtonTapped: () -> Void
    
    var body: some View {
        ZStack {
            Color("primaryGreen")
                .ignoresSafeArea(edges: .top)
            
                HStack {
                    // left Button (back arrow or menu icon)
                    Button(action: onHeaderButtonTapped) {
                        Image(systemName: showBackButton ? "arrow.backward" : "line.3.horizontal")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.white)
                            .padding(10)
                    }
                    
                    Spacer()
                    
                    Text(title)
                        .font(.custom("BalooBhaina2-Bold", size: 26))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Spacer()
                    Spacer().frame(width: 40)
                }
                .padding(.horizontal)
                .padding(.top, 70)
        }
            .frame(height: 150)
    }
}
