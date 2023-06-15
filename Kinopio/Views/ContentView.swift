import SwiftUI

struct ContentView: View {
    @State var isLoading = false
    @SceneStorage("url") var url = Configuration.webURL
    @SceneStorage("backgroundColor") var backgroundColor = Color.white
    @State private var backgroundTintColor: Color? = nil
    @State private var showAddToInput = false
    
    @ViewBuilder
    var Background: some View {
        if let backgroundTintColor {
            backgroundColor.colorMultiply(backgroundTintColor)
        } else {
            backgroundColor
        }
    }
    
    var body: some View {
        ZStack {
            Background
                .ignoresSafeArea()
            
            if isLoading {
                VStack {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .padding(.bottom)
                }
                .transition(.opacity.animation(.default))
            }
            
            WebViewWrapper(
                url: $url,
                isLoading: $isLoading,
                backgroundColor: $backgroundColor,
                backgroundTintColor: $backgroundTintColor
            )
            .ignoresSafeArea()
            .opacity(isLoading ? 0 : 1)
            .animation(.default, value: isLoading)
            .sheet(isPresented: $showAddToInput) {
                AddToInboxView()
                    .presentationDetents([.height(240)])
            }
            .onOpenURL { url in
                if url.path == ("/add") {
                    showAddToInput = true
                }
            }
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
