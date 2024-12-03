import SwiftUI

struct FinalizeAccount2: View {
    @State private var inputNumber = ""
    @State private var alwaysShowProfileChecked = false
    @State private var manuallyEnableChecked = false
    @Binding var selectedFrequency: String

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    
                    // Progress Indicator View
                    ProgressIndicatorView4()
                        .padding(.top, 70)
                    
                    // Title Text
                    VStack(spacing: -50) {
                        Text("Finalize Your")
                            .font(.custom("BalooBhaina2-Bold", size: 48))
                            .foregroundColor(Color(red: 0.35, green: 0.22, blue: 0.82))
                        
                        Text("Profile")
                            .font(.custom("BalooBhaina2-Bold", size: 48))
                            .foregroundColor(Color(red: 0.35, green: 0.22, blue: 0.82))
                    }
                    .multilineTextAlignment(.center)
                    .padding(.top, 10)
                    
                    // Question Text
                    VStack(alignment: .leading, spacing: -8) {
                        Text("About how many")
                            .font(.custom("BalooBhaina2-Bold", size: 30))
                            .foregroundColor(Color(red: 0.35, green: 0.22, blue: 0.82))
                        
                        Text("meal swipes can you give per week?")
                            .font(.custom("BalooBhaina2-Bold", size: 30))
                            .foregroundColor(Color(red: 0.35, green: 0.22, blue: 0.82))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 36)
                    .padding(.top, 10)
                    .padding(.bottom, 4)
                    
                    // Light Purple Input Bubble
                    HStack {
                        TextField("Enter a number", text: $inputNumber)
                            .padding(.horizontal, 16)
                            .frame(height: 40)
                            .background(Color(red: 0.85, green: 0.82, blue: 0.95).opacity(0.6))
                            .cornerRadius(100)
                            .padding(.top, 20)
                            .keyboardType(.numberPad) // Ensure numeric input
                    }
                    .padding(.horizontal, 56)
                    .padding(.top, 8)
                    
                    // Second Question Text
                    VStack(alignment: .leading, spacing: -8) {
                        Text("Always show profile")
                            .font(.custom("BalooBhaina2-Bold", size: 30))
                            .foregroundColor(Color(red: 0.35, green: 0.22, blue: 0.82))
                        
                        Text("to receivers?")
                            .font(.custom("BalooBhaina2-Bold", size: 30))
                            .foregroundColor(Color(red: 0.35, green: 0.22, blue: 0.82))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 36)
                    .padding(.top, 20)
                    
                    // Description Text
                    Text("If no, you will have to manually enable\nyour giving status when in a dining hall\nto have receivers request meal swipes.\nYou can change this setting at any time.")
                        .font(.system(size: 14))
                        .foregroundColor(Color.gray)
                        .padding(.leading, 36)
                        .padding(.top, 8)
                    
                    // "Yes" and "No" Options
                    HStack {
                        HStack {
                            Text("Yes")
                                .font(.custom("BalooBhaina2-Regular", size: 18))
                            CheckBoxView1(
                                isChecked: $alwaysShowProfileChecked,
                                label: "Yes",
                                selectedFrequency: $selectedFrequency,
                                onToggle: { manuallyEnableChecked = false }
                            )
                        }
                        
                        Spacer().frame(width: 20) // Space between "Yes" and "No"
                        
                        HStack {
                            Text("No")
                                .font(.custom("BalooBhaina2-Regular", size: 18))
                            CheckBoxView1(
                                isChecked: $manuallyEnableChecked,
                                label: "No",
                                selectedFrequency: $selectedFrequency,
                                onToggle: { alwaysShowProfileChecked = false }
                            )
                        }
                    }
                    .padding(.horizontal, 36)
                    .padding(.top, 8)
                    
                    // NavigationLink with validation
                    NavigationLink(destination: GiverHomeView()) {
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(Color(red: 0.6, green: 0.9, blue: 0.8)) // Light green circle
                                    .frame(width: 24, height: 24)
                                
                                Image(systemName: "chevron.right") // Caret pointing right
                                    .foregroundColor(.white)
                                    .font(.system(size: 14))
                            }
                            .padding(.trailing, 8) // Space between the circle and text
                            
                            Text("Start Swiping!")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .frame(width: 220, height: 50)
                        .background(LinearGradient(gradient: Gradient(colors: [
                            Color(red: 0.03, green: 0.75, blue: 0.72),
                            Color(red: 0.6, green: 0.9, blue: 0.8) // Lighter shade of green
                        ]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(100)
                    }
                    .padding(.top, 30)
                    .disabled(inputNumber.isEmpty || (!alwaysShowProfileChecked && !manuallyEnableChecked)) // Disable until conditions are met
                    .opacity(inputNumber.isEmpty || (!alwaysShowProfileChecked && !manuallyEnableChecked) ? 0.5 : 1.0) // Visual feedback
                }
                .frame(maxWidth: 480)
                .background(Color.white)
                .cornerRadius(32)
            }
            .background(Color.white)
            .edgesIgnoringSafeArea(.all)
        }
        .hideKeyboardOnTap()
        .navigationBarBackButtonHidden(true)
    }
}

// CheckBox View
struct CheckBoxView1: View {
    @Binding var isChecked: Bool
    let label: String
    @Binding var selectedFrequency: String
    var onToggle: () -> Void = {}
    
    var body: some View {
        Button(action: {
            isChecked.toggle()
            if isChecked {
                selectedFrequency = label
                onToggle()
            }
        }) {
            Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                .foregroundColor(isChecked ? Color(red: 0.03, green: 0.75, blue: 0.72) : .gray)
                .font(.system(size: 24))
        }
    }
}

// Progress Indicator View
struct ProgressIndicatorView4: View {
    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .center, spacing: 20) {
                Rectangle()
                    .fill(Color(red: 0.85, green: 0.82, blue: 0.95))
                    .frame(width: 108, height: 1)
                
                Rectangle()
                    .fill(Color(red: 0.85, green: 0.82, blue: 0.95))
                    .frame(width: 108, height: 1)
                
                Circle()
                    .strokeBorder(Color(red: 0.22, green: 0.11, blue: 0.47), lineWidth: 2)
                    .frame(width: 18, height: 18)
            }
            .frame(width: geometry.size.width, alignment: .center)
        }
        .frame(height: 20)
    }
}

extension View {
    func hideKeyboardOnTap() -> some View {
        self.onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

struct FinalizeAccount2_Previews: PreviewProvider {
    static var previews: some View {
        FinalizeAccount2(selectedFrequency: .constant("week"))
    }
}

