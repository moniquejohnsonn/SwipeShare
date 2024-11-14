//
//  receiverHome1.swift
//  SwipeShare
//
//  Created by Rosa Figueroa on 11/14/24.
//

import SwiftUI
import MapKit

struct ReceiverHomeView1: View {

    var body: some View {
        VStack(spacing: 0) {
            HeaderView(
                title: "Home",
                showBackButton: false,
                onHeaderButtonTapped: {
                    print("add navigation here")
                }
            )
            
            Text("Swipe Givers")
                .font(.custom("BalooBhaina2-Bold", size: 30))
                .foregroundColor(Color("primaryPurple"))
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .frame(alignment: .leading)
            
            ScrollView {
                ForEach(diningHalls, id: \.name) { hall in
                    let hallGivers = getGiversForDiningHall(givers: givers, diningHall: hall)
                    DiningHallRow(diningHall: hall, giverCount: hallGivers.count)
                }
            }
            .padding(.horizontal)
        }
        .background(Color("lightBackground"))
        .edgesIgnoringSafeArea(.top)
    }
}


struct DiningHallRow: View {
    let diningHall: DiningHall
    let giverCount: Int
    
    var body: some View {
        HStack {
            Spacer()
            Image("pin")
                .resizable()
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading) {
                Text(diningHall.name)
                    .font(.custom("BalooBhaina2-Bold", size: 20))
                    .foregroundColor(Color("darkestPurple"))
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
            }
            HStack {
                Image(systemName: "triangle.fill")
                    .resizable()
                    .frame(width: 14, height: 14)
                    .foregroundColor(Color("secondaryGreen"))
                
                Text("\(giverCount)")
                    .font(.custom("BalooBhaina2-Regular", size: 16))
                    .foregroundColor(.black)
            }
            Spacer()
        }
        .padding()
        .background(Color("secondaryPurple").opacity(0.5))
        .cornerRadius(16)
        .shadow(radius: 4)
        .padding(.vertical, 5)
    }
}

// Preview
struct ReceiverHomeView_Previews: PreviewProvider {
    static var previews: some View {
        ReceiverHomeView1()
    }
}
