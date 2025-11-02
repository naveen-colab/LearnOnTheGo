import SwiftUI

struct PlayLearningCardScreen: View {
    let title: String
    let image: Image

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
//                // Red header bar with back chevron and "Now playing"
//                HStack(spacing: 6) {
//                    Image(systemName: "chevron.backward")
//                    Text("Now playing")
//                        .fontWeight(.medium)
//                }
//                .foregroundColor(.white)
//                .padding(.vertical, 10)
//                .padding(.horizontal, 16)
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .background(Color.red)
                
                // Image in rounded rectangle container
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding(.horizontal)
                
                // Title centered, bold, slightly larger font
                Text(title)
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Subtitle line "Episode • 8 min" in secondary style
                Text("Episode • 8 min")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Progress row
                HStack {
                    Image(systemName: "gauge")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("02:15 / 08:00")
                        .font(.subheadline.monospacedDigit())
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                ProgressView(value: 135, total: 480)
                    .tint(.red)
                    .padding(.horizontal)
                
                // Transport controls
                HStack(spacing: 60) {
                    Button {
                        // back action
                    } label: {
                        Image(systemName: "backward.fill")
                            .font(.title2)
                            .foregroundColor(.primary)
                    }
                    Button {
                        // play action
                    } label: {
                        Image(systemName: "play.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(Circle().fill(Color.red))
                    }
                    Button {
                        // forward action
                    } label: {
                        Image(systemName: "forward.fill")
                            .font(.title2)
                            .foregroundColor(.primary)
                    }
                }
                .padding(.vertical)
                
                // Transcript section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Transcript")
                        .font(.headline)
                        .padding(.bottom, 4)
                    
                    // Paragraphs: first paragraph red, rest default
                    Group {
                        Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.")
                            .foregroundColor(.red)
                        Text("Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.")
                        Text("Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.")
                        Text("Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")
                    }
                    .font(.body)
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
            .frame(maxWidth: .infinity)
            .navigationTitle("Now playing")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.red, for: .navigationBar)
            .toolbarBackgroundVisibility(.visible, for: .navigationBar)
        }
    }
}

#Preview {
    NavigationStack {
        PlayLearningCardScreen(title: "Learn SwiftUI Basics", image: Image(systemName: "play.rectangle.fill"))
    }
}
