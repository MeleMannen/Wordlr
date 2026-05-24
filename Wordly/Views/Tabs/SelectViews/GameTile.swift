import SwiftUI

public struct GameTile: View {
    public let letter: String
    public let fill: Color
    public let textColor: Color
    public let size: CGFloat = 48
    public let cornerRadius: CGFloat = 8

	public init(letter: String, fill: Color, textColor: Color) {
        self.letter = letter
        self.fill = fill
        self.textColor = textColor
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
    }
}

struct AnimatedGameTile: View {
    let letter: Letter
    let tileSize: CGFloat
    let colIndex: Int
    let rowIndex: Int
    let currentRow: Int
    let boardCount: Int
    let isShaking: Bool
    let isResettingBoard: Bool
    let selectedGameMode: GameMode
    let didWinGame: GameEndState
    let isGameOver: Bool
    let userWantsNormalTheme: Bool
    let colorScheme: ColorScheme
    let colorForUnused: Color
    let gradient: LinearGradient
    let shadowGradient: LinearGradient
    var onRevealStart: (() -> Void)?
    var onRevealComplete: (() -> Void)?

    @State private var spinDegrees = 0.0
    @State private var tileScale = 1.0
    @State private var displayedState: LetterState
    @State private var animationGeneration = 0

    init(
        letter: Letter,
        tileSize: CGFloat,
        colIndex: Int,
        rowIndex: Int,
        currentRow: Int,
        boardCount: Int,
        isShaking: Bool,
        isResettingBoard: Bool,
        selectedGameMode: GameMode,
        didWinGame: GameEndState,
        isGameOver: Bool,
        userWantsNormalTheme: Bool,
        colorScheme: ColorScheme,
        colorForUnused: Color,
        gradient: LinearGradient,
        shadowGradient: LinearGradient,
        onRevealStart: (() -> Void)? = nil,
        onRevealComplete: (() -> Void)? = nil
    ) {
        self.letter = letter
        self.tileSize = tileSize
        self.colIndex = colIndex
        self.rowIndex = rowIndex
        self.currentRow = currentRow
        self.boardCount = boardCount
        self.isShaking = isShaking
        self.isResettingBoard = isResettingBoard
        self.selectedGameMode = selectedGameMode
        self.didWinGame = didWinGame
        self.isGameOver = isGameOver
        self.userWantsNormalTheme = userWantsNormalTheme
        self.colorScheme = colorScheme
        self.colorForUnused = colorForUnused
        self.gradient = gradient
        self.shadowGradient = shadowGradient
        self.onRevealStart = onRevealStart
        self.onRevealComplete = onRevealComplete
        _displayedState = State(initialValue: letter.state)
    }

    private var tileSpring: Animation {
        .interpolatingSpring(mass: 0.7, stiffness: 100, damping: 8, initialVelocity: 1)
            .speed(1)
            .delay(0)
    }

    var body: some View {
        Text(letter.letter)
            .font(.largeTitle).bold()
            .foregroundStyle(tileTextColor)
            .frame(width: tileSize, height: tileSize)
            .background(tileBackground)
            .rotationEffect(.degrees(spinDegrees), anchor: .center)
            .scaleEffect(tileScale, anchor: .center)
            .offset(x: rowIndex == currentRow ? (isShaking ? -15 : 0) : 0)
            .onChange(of: letter.id, initial: true) {
                prepareForCurrentLetterIdentity()
            }
            .onChange(of: letter.state) {
                guard letter.state != .notUsed else { return }
                animateStateChange(to: letter.state)
            }
            .onChange(of: letter.letter) {
                guard !isResettingBoard else { return }
                if letter.letter.isEmpty {
                    animateRemove()
                } else {
                    animateTap()
                }
            }
    }

    @ViewBuilder
    private var tileBackground: some View {
		ZStack {
			RoundedRectangle(cornerRadius: 5)
				.fill(tileFill)

			RoundedRectangle(cornerRadius: 5)
				.foregroundStyle(gradient)
				.opacity(shouldUseCelebrationGradient ? 1 : 0)
				.gradientShadow(
					gradient: shadowGradient,
					radius: shouldUseCelebrationGradient ? 3 : 0,
					x: 0,
					y: 0
				)
		}
		.animation(
			celebrationGradientAnimation,
			value: shouldUseCelebrationGradient
		)
    }

    private var tileTextColor: Color {
        displayedState == .notUsed ? .black : .white
    }

    private var shouldUseCelebrationGradient: Bool {
        !userWantsNormalTheme &&
        colorScheme == .dark &&
        selectedGameMode == .dailyWord &&
        didWinGame == .won &&
        isGameOver &&
        !isResettingBoard &&
        (rowIndex == currentRow - 1 || rowIndex == boardCount)
    }

	private var celebrationGradientAnimation: Animation {
		if shouldUseCelebrationGradient {
			.easeInOut(duration: 0.45).delay(Double(colIndex) * 0.06)
		} else {
			.linear(duration: 0.001)
		}
	}

    private var tileFill: Color {
        switch displayedState {
            case .correctPosition:
                return .green
            case .correctLetter:
                return .orange
            case .usedButNotCorrect:
                return Color(UIColor.darkGray)
            case .notUsed:
                return colorForUnused
        }
    }

    private func prepareForCurrentLetterIdentity() {
        animationGeneration += 1
        displayedState = letter.state

        if isResettingBoard {
            animateSpringSpin(generation: animationGeneration)
        } else {
            spinDegrees = 0
            tileScale = 1.0
        }
    }

    private func animateStateChange(to state: LetterState) {
        animationGeneration += 1
        animateSpringSpin(
            to: state,
            delay: Double(colIndex) * 0.3,
            generation: animationGeneration
        )
    }

    private func animateSpringSpin(to state: LetterState? = nil, delay: Double = 0, generation: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            guard generation == animationGeneration else { return }

            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                if let state {
                    displayedState = state
                }
                spinDegrees = 0
                tileScale = 1.0
            }

            onRevealStart?()

            withAnimation(tileSpring) {
                spinDegrees = 360
            } completion: {
                onRevealComplete?()
            }
        }
    }

    private func animateTap() {
        tileScale = 1.1
        withAnimation(tileSpring) {
            tileScale = 1.0
        }
    }

    private func animateRemove() {
        tileScale = 0.87
        withAnimation(tileSpring) {
            tileScale = 1.0
        }
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
