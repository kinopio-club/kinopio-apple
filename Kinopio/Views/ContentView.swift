import SwiftUI

struct ContentView: View {
    @State var isLoading = false
    @SceneStorage("url") var url = Configuration.webURL
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea(.all)
            
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
                isLoading: $isLoading
            )
            .ignoresSafeArea(edges: [.bottom, .horizontal])
            .opacity(isLoading ? 0 : 1)
            .animation(.default, value: isLoading)
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
