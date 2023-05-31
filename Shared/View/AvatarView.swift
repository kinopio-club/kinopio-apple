import SwiftUI

struct AvatarView: View {
    var color: Color = .accentColor
    var size: Double = 40
    
    var cornerRadius: Double { size / 40 * 6 }
    
    var body: some View {
        VStack {
            Image("avatar")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(5)
                .foregroundColor(color.isDark ? .white : .black)
        }
        .frame(width: size, height: size)
        .background(color)
        .cornerRadius(cornerRadius)
    }
}

struct AvatarView_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            AvatarView()
            
            AvatarView(color: .green)
            
            AvatarView(color: .cyan)
            
            AvatarView(color: .brown)
            
            AvatarView(color: .black)
            
            AvatarView(color: .red, size: 20)
        }
    }
}
