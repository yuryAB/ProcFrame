struct SpriteKitPanelView: View {
    var scene: SKScene

    var body: some View {
        SpriteView(scene: scene)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black) 
            .cornerRadius(8)
            .shadow(radius: 4)
    }
}