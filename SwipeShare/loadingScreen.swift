import SwiftUI

struct loadingScreen: View {
    
        var body: some View {
            HeaderView(
                            title: "Loading Screen",
                            showBackButton: false, // Hides the back button
                            onHeaderButtonTapped: { /* No action needed */ }
                        )
            ZStack {
                Color(red: 0.027, green: 0.745, blue: 0.722).ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    Image("LogoIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 350, height: 400)
                    
                    Spacer()
                    
                    Text("Loading...")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(2)
                    Spacer()
                }
                .navigationBarBackButtonHidden(true)
            }
        }
    
       
}

#Preview {
  
                loadingScreen()
           
}
