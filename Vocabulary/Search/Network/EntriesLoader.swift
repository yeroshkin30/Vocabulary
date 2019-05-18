//
//	EntriesLoader.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 9/4/17.
//	Copyright © 2017 Alexander Baraley. All rights reserved.
//

//www.dictionaryapi.com/api/v1/references/learners/xml/\(query)
//?key=51f724d8-256f-4237-831b-3e8fe0e2c2ea

import Foundation

enum EntriesParsingResult: Equatable {
	case entries([Entry])
	case suggestions([String])
}

class EntriesLoader {
	
	private let baseURLString = "https://www.dictionaryapi.com"
	private let apiKey = "51f724d8-256f-4237-831b-3e8fe0e2c2ea"
	private let learnersDicPath = "/api/v1/references/learners/xml/"
	
	private let parserDelegate: EntriesParserDelegate
	
	init(with parserDelegate: EntriesParserDelegate = EntriesParserDelegate()) {
		self.parserDelegate = parserDelegate
	}
	
	func requestEntriesFor(_ word: String, with completion: @escaping (EntriesParsingResult?) -> ()) {
		let url = entriesRequestURL(for: word)
		let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 5.0)
		
		let dataTask = URLSession.shared.dataTask(with: request, completionHandler: {
			(data, _, error) in
			
			if let data = data {
				let result = self.parserDelegate.parseEntriesFrom(data)
				completion(result)
			} else {
				print(error?.localizedDescription ?? "Data loading error")
				completion(nil)
			}
		})
		dataTask.resume()
	}
	
	private func entriesRequestURL(for word: String) -> URL {
		var urlComponents = URLComponents(string: baseURLString)!
		
		urlComponents.path = learnersDicPath + word.trimmingCharacters(in: .whitespacesAndNewlines)
		urlComponents.queryItems = [URLQueryItem(name: "key", value: apiKey)]
		
		return urlComponents.url!
	}
}
