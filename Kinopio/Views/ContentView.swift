import SwiftUI
import StoreKit

struct ContentView: View {
    @State var isLoading = false
    @SceneStorage("url") var url = Configuration.webURL
    @SceneStorage("backgroundColor") var backgroundColor = Color.white
    @State private var showAddToInput = false
    @State private var isManageSubscriptionsSheetVisible = false
    
    private func onOpenURL(_ url: URL) {
        if url.path == ("/add") {
            showAddToInput = true
        } else {
            self.url = url
        }
    }
    
    private func onClose(_ url: URL?) {
        showAddToInput.toggle()
        if let url {
            onOpenURL(url)
        }
    }
    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea(.all)
            
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
                isManageSubscriptionsSheetVisible: $isManageSubscriptionsSheetVisible
            )
            .ignoresSafeArea()
            .opacity(isLoading ? 0 : 1)
            .animation(.default, value: isLoading)
            .sheet(isPresented: $showAddToInput) {
                AddToInboxView(onClose: onClose)
                    .presentationDetents([.height(240)])
            }
            .manageSubscriptionsSheet(isPresented: $isManageSubscriptionsSheetVisible)
            .onOpenURL(perform: onOpenURL)
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
