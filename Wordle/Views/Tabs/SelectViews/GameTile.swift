import SwiftUI

public struct GameTile: View {
    public let letter: String
    public let fill: Color
    public let textColor: Color
    public let size: CGFloat
    public let cornerRadius: CGFloat

    public init(letter: String, fill: Color, textColor: Color, size: CGFloat = 48, cornerRadius: CGFloat = 8) {
        self.letter = letter
        self.fill = fill
        self.textColor = textColor
        self.size = size
        self.cornerRadius = cornerRadius
    }

    public var body: some View {
        Text(letter)
            .font(.title2).bold()
            .foregroundStyle(textColor)
            .frame(width: size, height: size)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(fill)
            )
            .accessibilityLabel("\(letter) tile")
    }
}

#Preview {
    VStack(spacing: 8) {
        GameTile(letter: "W", fill: .green, textColor: .white)
        GameTile(letter: "O", fill: .orange, textColor: .white)
        GameTile(letter: "X", fill: Color(UIColor.darkGray), textColor: .white)
    }
    .padding()
}
