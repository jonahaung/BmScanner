//
//  Extensions.swift
//  Starter SwiftUI
//
//  Created by Aung Ko Min on 11/4/21.
//

import UIKit
import NaturalLanguage

extension NSMutableParagraphStyle {
    static var defaultStyle: NSMutableParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.lineBreakStrategy = .hangulWordPriority
        paragraphStyle.allowsDefaultTighteningForTruncation = true
        return paragraphStyle
    }
}
extension String {
    var noteAttributedText: NSAttributedString {
        let font = self.language == "my" ? UIFont.myanmarNoto : UIFont.engFont
        let attributes: [NSAttributedString.Key: Any] = [.font: font, .paragraphStyle: NSMutableParagraphStyle.defaultStyle, .foregroundColor: UIColor.label]
        return NSAttributedString(string: self, attributes: attributes)
        
    }
}
extension CharacterSet {
    
    static let removingCharacters = CharacterSet(charactersIn: "|+*#%;:&^$@!~.,'`|_ၤ”“")
    
    static let myanmarAlphabets = CharacterSet(charactersIn: "ကခဂဃငစဆဇဈညတဒဍဓဎထဋဌနဏပဖဗဘမယရလ၀သဟဠအ").union(.whitespacesAndNewlines)
    static let myanmarCharacters2 = CharacterSet(charactersIn: "ါာိီုူေဲဳဴဵံ့း္်ျြွှ")
    static var englishAlphabets = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ ")
    static var lineEnding = CharacterSet(charactersIn: ".,?!;:။…\n\t")
}
extension String {
    
    var language: String {
        
        return NSLinguisticTagger.dominantLanguage(for: self) ?? ""
    }
    func cleanUpMyanmarTexts() -> String {
        var texts = self
        if let range = self.rangeOfCharacter(from: CharacterSet.removingCharacters) {
            texts = self.replacingCharacters(in: range, with: " ")
        }
        
        //        let segs = MyanmarReSegment.segment(self)
        //        print(segs)
        //        var filtered = [String]()
        //        segs.forEach { seg in
        //            var new = seg
        //            if replaces.contains(seg) {
        //                new = " "
        //            }
        //            filtered.append(new)
        //        }
        return texts
    }
    
    var trimmed: String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var urlDecoded: String {
        return removingPercentEncoding ?? self
    }
    
    var urlEncoded: String {
        return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? self
    }
    
    var isWhitespace: Bool {
        return trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    var withoutSpacesAndNewLines: String {
        return replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\n", with: "")
    }
}
extension String {
    func exclude(in set: CharacterSet) -> String {
        let filtered = unicodeScalars.lazy.filter { !set.contains($0) }
        return String(String.UnicodeScalarView(filtered))
    }
    func include(in set: CharacterSet) -> String {
        let filtered = unicodeScalars.lazy.filter { set.contains($0) }
        return String(String.UnicodeScalarView(filtered))
    }
    
    func lines() -> [String] {
        var result = [String]()
        enumerateLines { line, _ in
            result.append(line)
        }
        return result
    }
    
    func words() -> [String] {
        let comps = components(separatedBy: CharacterSet.whitespacesAndNewlines)
        return comps.filter { !$0.isWhitespace }
    }
    
    public func contains(_ string: String, caseSensitive: Bool = true) -> Bool {
        if !caseSensitive {
            return range(of: string, options: .caseInsensitive) != nil
        }
        return range(of: string) != nil
    }
    
}

extension String {
    
    var EXT_isMyanmarCharacters: Bool {
        return self.rangeOfCharacter(from: CharacterSet.myanmarAlphabets) != nil
    }
    var EXT_isEnglishCharacters: Bool {
        return self.rangeOfCharacter(from: CharacterSet.englishAlphabets) != nil
    }
    
    var firstWord: String {
        return words().first ?? self
    }
    
    func lastWords(_ max: Int) -> [String] {
        return Array(words().suffix(max))
    }
    var lastWord: String {
        return words().last ?? self
    }
    
    var firstLetterCapitalized: String {
        guard !isEmpty else { return self }
        return prefix(1).capitalized + dropFirst()
    }
    
    var lastCharacterAsString: String {
        if let lastChar = self.last {
            return String(lastChar)
        }
        return ""
    }
}




extension UIApplication {
    
    class func getRootViewController() -> UIViewController? {
        var rootVC: UIViewController? = nil
        for scene in UIApplication.shared.connectedScenes {
            if scene.activationState == .foregroundActive {
                rootVC = ((scene as? UIWindowScene)!.delegate as! UIWindowSceneDelegate).window!!.rootViewController
                break
            }
        }
        return rootVC
    }
    
    class func getTopViewController(base: UIViewController? = UIApplication.getRootViewController()) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)
            
        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return getTopViewController(base: selected)
            
        } else if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return base
    }
}

extension Bundle {
    var version: String? {
        return self.infoDictionary?["CFBundleShortVersionString"] as? String
    }
}

extension DateFormatter {
    
    static let relativeDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()
}
