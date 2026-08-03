//
//  KeyPress.swift
//  Wordlr
//
//  Created by Kristoffer Melen on 03/11/2025.
//

import UIKit
import SwiftUI

private struct Shortcut: Hashable {
	let input: String
	let modifiers: UIKeyModifierFlags
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(input)
		hasher.combine(modifiers.rawValue)
	}
	static func == (lhs: Self, rhs: Self) -> Bool {
		lhs.input == rhs.input && lhs.modifiers.rawValue == rhs.modifiers.rawValue
	}
}

private final class KeyCommandsController: UIViewController {
	var handlers: [Shortcut: () -> Void] = [:]
	var letterHandler: ((String) -> Void)?
	
	override var canBecomeFirstResponder: Bool { true }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		becomeFirstResponder()
	}
	
	override var keyCommands: [UIKeyCommand]? {
		[
			UIKeyCommand(input: UIKeyCommand.inputDelete, modifierFlags: [], action: #selector(handleKeyCommand(_:))),
			UIKeyCommand(input: "\r", modifierFlags: [], action: #selector(handleKeyCommand(_:))),
			UIKeyCommand(input: "r", modifierFlags: .command, action: #selector(handleKeyCommand(_:))),
			UIKeyCommand(input: "n", modifierFlags: .command, action: #selector(handleKeyCommand(_:))),
			UIKeyCommand(input: "c", modifierFlags: .command, action: #selector(handleKeyCommand(_:))),
			UIKeyCommand(input: "h", modifierFlags: [.command, .alternate], action: #selector(handleKeyCommand(_:)))
		]
	}
	
	override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
		var handled = false
		for press in presses {
			guard let key = press.key else { continue }
			
			let chars = key.charactersIgnoringModifiers
			if key.modifierFlags.isEmpty,
			   chars.count == 1,
			   chars.unicodeScalars.allSatisfy({ CharacterSet.letters.contains($0) }) {
				letterHandler?(chars.uppercased())
				handled = true
			}
		}
		if handled { return }
		super.pressesBegan(presses, with: event)
	}
	
	@objc private func handleKeyCommand(_ sender: UIKeyCommand) {
		let input = (sender.input ?? "").lowercased()
		let mods = sender.modifierFlags
		
		if mods == .command, input == "r" { handlers[Shortcut(input: "r", modifiers: .command)]?(); return }
		if mods == .command, input == "n" { handlers[Shortcut(input: "n", modifiers: .command)]?(); return }
		if mods == .command, input == "c" { handlers[Shortcut(input: "c", modifiers: .command)]?(); return }
		if mods == [.command, .alternate], input == "h" { handlers[Shortcut(input: "h", modifiers: [.command, .alternate])]?(); return }
		
		if mods.isEmpty, input == UIKeyCommand.inputDelete {
			handlers[Shortcut(input: UIKeyCommand.inputDelete, modifiers: [])]?()
			return
		}
		if mods.isEmpty, input == "\r" {
			handlers[Shortcut(input: "\r", modifiers: [])]?()
			return
		}
	}
}

private struct KeyCommandBridge: UIViewControllerRepresentable {
	var onInsertLetter: (String) -> Void = { _ in }
	var onDelete: () -> Void = {}
	var onReturn: () -> Void = {}
	var onCommandR: () -> Void = {}
	var onCommandN: () -> Void = {}
	var onCommandC: () -> Void = {}
	var onCommandOptionH: () -> Void = {}
	
	func makeUIViewController(context: Context) -> KeyCommandsController {
		let vc = KeyCommandsController()
		vc.letterHandler = onInsertLetter
		vc.handlers[Shortcut(input: UIKeyCommand.inputDelete, modifiers: [])] = onDelete
		vc.handlers[Shortcut(input: "\r", modifiers: [])] = onReturn
		vc.handlers[Shortcut(input: "r", modifiers: .command)] = onCommandR
		vc.handlers[Shortcut(input: "n", modifiers: .command)] = onCommandN
		vc.handlers[Shortcut(input: "c", modifiers: .command)] = onCommandC
		vc.handlers[Shortcut(input: "h", modifiers: [.command, .alternate])] = onCommandOptionH
		return vc
	}
	
	func updateUIViewController(_ uiViewController: KeyCommandsController, context: Context) {}
}

extension View {
	@ViewBuilder
	func hardwareKeyCommands(
		onInsertLetter: @escaping (String) -> Void = { _ in },
		onDelete: @escaping () -> Void = {},
		onReturn: @escaping () -> Void = {},
		onCommandR: @escaping () -> Void = {},
		onCommandN: @escaping () -> Void = {},
		onCommandC: @escaping () -> Void = {},
		onCommandOptionH: @escaping () -> Void = {}
	) -> some View {
		KeyCommandBridge(
			onInsertLetter: onInsertLetter,
			onDelete: onDelete,
			onReturn: onReturn,
			onCommandR: onCommandR,
			onCommandN: onCommandN,
			onCommandC: onCommandC,
			onCommandOptionH: onCommandOptionH
		)
		.allowsHitTesting(false)
	}
}
