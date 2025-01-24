import SwiftUI

struct SplashScreen: View {
    @AppStorage("shouldShowOnboarding") var shouldShowOnboarding: Bool = true
    
    // State variables for animation
    @State private var glowIntensity: CGFloat = 0
    @State private var isMovedToLeft = false
    @State private var isMovedToRight = false
    @State private var opacity: Double = 0.0 // Start with no opacity for both texts
    @State private var opacityForGetTimeBack: Double = 0.0 // Opacity for "Get your time back"
    @State private var glowing = false // Track the glowing state
    @State private var gradientStart = [Color.black, Color.blue] // Start colors of the gradient
    @State private var gradientEnd = [Color.black, Color.blue]  // End colors of the gradient
    
    var body: some View {
        ZStack {
            // Animated Background Gradient
            LinearGradient(gradient: Gradient(colors: gradientStart), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
                .onAppear {
                    // Animate the gradient start and end colors
                    withAnimation(
                        Animation.linear(duration: 5)
                    ) {
                        gradientStart = [Color.black, Color.black] // Animate colors to new set
                        gradientEnd = [Color.white, Color.black]  // Animate colors to new set
                    }
                }
                .overlay(
                    // Glowing Effect using animation
                    LinearGradient(gradient: Gradient(colors: [Color.black.opacity(glowIntensity), Color.black.opacity(glowIntensity)]), startPoint: .top, endPoint: .bottom)
                        .blur(radius: 0) // Blur to make the glow more intense
                        .blendMode(.screen)
                )
                .overlay(
                    // Additional glowing layer to intensify the effect
                    LinearGradient(gradient: Gradient(colors: [Color.black.opacity(glowIntensity * 0.1), Color.black.opacity(glowIntensity * 0.1)]), startPoint: .top, endPoint: .bottom)
                        .blur(radius: 0) // More blur for an even stronger glow
                        .blendMode(.screen)
                )
            
            ZStack {
                VStack {
                    Text("LOCK IN")
                        .opacity(opacity)
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundColor(.white)
                        .scaledToFit()
                        .offset(x: isMovedToRight ? 50 : 0) // Move the image to the left but stop before the edge
                        .animation(
                            .easeInOut(duration: 2),
                            value: isMovedToRight
                        )
                    
                    Text("Get your time back")
                        .opacity(opacityForGetTimeBack) // Opacity tied to the delay
                        .font(.subheadline)
                        .italic()
                        .fontWeight(.regular)
                        .foregroundColor(.white)
                        .scaledToFit()
                        .offset(x: isMovedToRight ? 50 : 0) // Move the image to the left but stop before the edge
                        .animation(
                            .easeInOut(duration: 2),
                            value: isMovedToRight
                        )
                }
                
                HStack {
                    Image("LockInIcon") // Replace with your image name
                        .resizable()        // Make the image resizable
                        .scaledToFit()      // Scale the image to fit within the view
                        .frame(width: 80, height: 80) // Set a specific size for the image
                        .offset(x: isMovedToLeft ? -80 : 0) // Move the image to the left but stop before the edge
                        .animation(
                            .easeInOut(duration: 2), // Only run the animation once
                            value: isMovedToLeft // Trigger the animation when this value changes
                        )
                }
                .onAppear {
                    // Start the animation as soon as the view appears
                    isMovedToLeft.toggle()
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isMovedToRight.toggle()
                    withAnimation(
                        .easeInOut(duration: 2)
                    ) {
                        opacity = 1 // Fade the "LOCK IN" text to full opacity
                    }
                }
                
                // Add delay for the "Get your time back" text
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) { // Delay for 1 second
                    withAnimation(.easeInOut(duration: 2)) {
                        opacityForGetTimeBack = 1 // Fade in "Get your time back" text after the delay
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    shouldShowOnboarding = false
                }
            }
        }
    }
}
