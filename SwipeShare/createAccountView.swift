import SwiftUI

struct SignUpView: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {

                ProgressIndicatorView()
                    .padding(.top, 64)

                Text("Create Account")
                    .font(.custom("BalooBhaina2-Bold", size: 48))
                    .foregroundColor(Color(red: 0.35, green: 0.22, blue: 0.82))
                    .padding(.top, 112)


                VStack(spacing: 14) {
                    InputFieldView(iconName: "nameIcon", placeholder: "name", text: $name)
                    InputFieldView(iconName: "emailIcon", placeholder: "email", text: $email)
                    InputFieldView(iconName: "passwordIcon", placeholder: "password", text: $password, isSecure: true)
                }
                .padding(.top, 56)

                Button(action: {
                    // Handle continue action
                }) {
                    Text("Continue")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(.white))
                        .frame(width: 93, height: 35)
                        .background(Color(red: 0.03, green: 0.75, blue: 0.72))
                        .cornerRadius(100)
                }
                .padding(.top, 128)

                HStack(spacing: 0) {
                    Text("Already have an account? ")
                        .foregroundColor(Color(red: 0.22, green: 0.11, blue: 0.47))
                    Text("Login")
                        .foregroundColor(Color(red: 0.22, green: 0.11, blue: 0.47))
                        .underline()
                }
                .font(.system(size: 16, weight: .medium))
                .padding(.top, 144)
                .padding(.bottom, 16)
            }
            .frame(maxWidth: 480)
            .background(Color.white)
            .cornerRadius(32)
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}

// Status Bar View


// Progress Indicator View
struct ProgressIndicatorView: View {
    var body: some View {
        HStack(spacing: 20) {
            HStack(spacing: 6) {
                Circle()
                    .strokeBorder(Color(red: 0.22, green: 0.11, blue: 0.47), lineWidth: 2)
                    .frame(width: 18, height: 18)
                
                Rectangle()
                    .fill(Color(red: 0.85, green: 0.82, blue: 0.95))
                    .frame(width: 108, height: 1)
            }
            
            Rectangle()
                .fill(Color(red: 0.85, green: 0.82, blue: 0.95))
                .frame(width: 108, height: 1)
        }
        .frame(maxWidth: 260)
    }
}

// Input Field View


struct InputFieldView: View {
    let iconName: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            // Icon positioned outside the purple bubble
            Image(iconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)

            // Purple bubble containing only the text field
            HStack {
                Group {
                    if isSecure {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text)
                    }
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(red: 0.13, green: 0.13, blue: 0.13))
            }
            .padding(.horizontal, 16)
            .frame(height: 40)
            .background(Color(red: 0.85, green: 0.82, blue: 0.95).opacity(0.3))
            .cornerRadius(100)
        }
        .padding(.horizontal, 16) // Add padding to both sides of the HStack
    }
}


