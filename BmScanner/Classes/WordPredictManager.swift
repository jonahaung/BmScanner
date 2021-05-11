//
//  Tagger.swift
//  Myanmar Text Grabber
//
//  Created by Aung Ko Min on 7/11/20.
//

import UIKit

class WordPredictManager {

    
    private var markovModel: MarkovModel<String>?
    static let shared = WordPredictManager()
    
    private var words = [String]()
    
    private lazy var textChecker = UITextChecker()
    
//    func train() {
//        let path = Bundle.main.path(forResource: "word", ofType: "txt") // file path for file "data.txt"
//
//        let string = try! String(contentsOfFile: path!, encoding: .utf8)
//        let lines = string.components(separatedBy: .lineEnding)
//        var wordsArray = [String]()
//        lines.forEach{
//            let words = $0.components(separatedBy: .whitespaces)
//            wordsArray += words
//        }
//
//        markovModel = MarkovModel(transitions: wordsArray)
//    }
//
    init() {
        
        let string = try! String(contentsOfFile: Bundle.main.path(forResource: "words2", ofType: "txt")!, encoding: .utf8)
        for word in string.lines() {
            self.words.append(word.trimmed.urlEncoded)
        }
        
        markovModel = MarkovModel(transitions: words)
    }
    
//    func makeJson() {
//        
//        let words = try! String(contentsOfFile: Bundle.main.path(forResource: "word", ofType: "txt")!, encoding: .utf8)
//        let tags = try! String(contentsOfFile: Bundle.main.path(forResource: "tag", ofType: "txt")!, encoding: .utf8)
//        
//        let wordLines = words.components(separatedBy: .newlines)
//        let tagLines = tags.components(separatedBy: .newlines)
//        
//        var dicts = [[String: Any]]()
//        
//        for (i, line) in wordLines.enumerated() {
//            let tagLine = tagLines[i]
//            let dic = ["tokens": line.components(separatedBy: .whitespaces), "labels": tagLine.components(separatedBy: .whitespaces)]
//            dicts.append(dic)
//            
//        }
//        
//        let jsonData = try! JSONSerialization.data(withJSONObject: ["data": dicts], options: JSONSerialization.WritingOptions.prettyPrinted)
//
//        let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
//        if let documentDirectory = FileManager.default.urls(for: .documentDirectory,
//                                                            in: .userDomainMask).first {
//            let pathWithFilename = documentDirectory.appendingPathComponent("myJsonString.json")
//            do {
//                try jsonString.write(to: pathWithFilename,
//                                     atomically: true,
//                                     encoding: .utf8)
//            } catch {
//                // Handle error
//            }
//        }
//        print(jsonString)
//    }
//
    
    func trainPrediction(string: String) {
        let array = string.words()
        markovModel = MarkovModel(transitions: array)
    }
    func pridict(text: String) -> String? {
        return markovModel?.chain.next(given: text)
    }
    
    func possible(text: String) -> [String]? {
        if let x = markovModel?.chain.probabilities(given: text) {
            return x.keys.map{$0}
        }
        return nil
    }
    
    private var previous: String?
    
    func completion(myanmar word: String) -> [String] {
        let predicate = NSPredicate(format: "SELF BEGINSWITH[cd] %@", word.urlEncoded)
        var array = (words as NSArray).filtered(using: predicate) as! [String]
        
        array = array.sorted{ $0.utf16.count < $1.utf16.count }
        
       
        return array.map{$0.urlDecoded}
    }
    
    func completion(english word: String) -> [String] {
        
        let completions = textChecker.completions(forPartialWordRange: NSRange(0..<word.utf16.count), in: word, language: "en_US") ?? []
        
        let predicate = NSPredicate(format: "SELF BEGINSWITH[cd] %@", word)
        
        let array = (completions as NSArray).filtered(using: predicate) as! [String]
        
//        array = array.sorted{ $0.utf16.count < $1.utf16.count }
        
        return array
    }
}
