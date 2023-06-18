//
//	SpeechSynthesizer.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 3/4/18.
//	Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit
import AVFoundation

extension UIViewController {
	
	static var speechSynthesizer: AVSpeechSynthesizer = {
		let audioSession = AVAudioSession.sharedInstance()
		try? audioSession.setCategory(.ambient, mode: .spokenAudio, options: [.duckOthers])
		return AVSpeechSynthesizer()
	}()
	
	func pronounce(_ text: String) {
		guard !text.isEmpty else { return }
		let utterance = AVSpeechUtterance(string: text)
		utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
		stopPronouncing()
		UIViewController.speechSynthesizer.speak(utterance)
	}
	
	func stopPronouncing() {
		if UIViewController.speechSynthesizer.isSpeaking == true {
			UIViewController.speechSynthesizer.stopSpeaking(at: .immediate)
		}
	}
	
	// MARK: - Child view controllers -
	
	func add(_ child: UIViewController) {
		addChild(child)
		child.willMove(toParent: self)
		view.addSubview(child.view)
		child.didMove(toParent: self)
	}
	
	func remove() {
		guard parent != nil else { return }
		
		willMove(toParent: nil)
		view.removeFromSuperview()
		removeFromParent()
	}
}
