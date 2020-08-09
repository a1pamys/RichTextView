//
//  NSMutableAttributedStringExtension.swift
//  RichTextView
//
//  Created by Ahmed Elkady on 2018-11-20.
//  Copyright © 2018 Top Hat. All rights reserved.
//

extension NSAttributedString.Key {
    static let customLink = NSAttributedString.Key(rawValue: "customLink")
    static let highlight = NSAttributedString.Key(rawValue: "highlight")
}

extension NSAttributedString {
    func attributedStringWithResizedImages(with maxWidth: CGFloat) -> NSAttributedString {
        let text = NSMutableAttributedString(attributedString: self)
        text.enumerateAttribute(NSAttributedString.Key.attachment, in: NSMakeRange(0, text.length), options: .init(rawValue: 0), using: { (value, range, stop) in
            if let attachement = value as? NSTextAttachment {
                let image = attachement.image(forBounds: attachement.bounds, textContainer: NSTextContainer(), characterIndex: range.location)!
                if image.size.width > maxWidth {
                    let newImage = image.resizeImage(scale: maxWidth/image.size.width)
                    let newAttribut = NSTextAttachment()
                    newAttribut.image = newImage
                    text.addAttribute(NSAttributedString.Key.attachment, value: newAttribut, range: range)
                }
            }
        })
        return text
    }
}

extension UIImage {
    func resizeImage(scale: CGFloat) -> UIImage {
        let newSize = CGSize(width: self.size.width*scale, height: self.size.height*scale)
        let rect = CGRect(origin: CGPoint.zero, size: newSize)

        UIGraphicsBeginImageContext(newSize)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}

extension NSMutableAttributedString {
    func replaceFont(with newFont: UIFont) {
        self.beginEditing()
        let defaultFontSize = UIFont.smallSystemFontSize
        self.enumerateAttribute(.font, in: NSRange(location: 0, length: self.length)) { (value, range, _) in
            guard let oldFont = value as? UIFont,
                let newFontDescriptor = newFont.fontDescriptor.withSymbolicTraits(oldFont.fontDescriptor.symbolicTraits) else {
                return
            }
            let mergedSize = oldFont.pointSize == defaultFontSize ? newFont.pointSize : oldFont.pointSize
            let mergedFont = UIFont(descriptor: newFontDescriptor, size: mergedSize)
            self.removeAttribute(.font, range: range)
            self.addAttribute(.font, value: mergedFont, range: range)
        }
        self.endEditing()
    }

    func replaceColor(with newColor: UIColor) {
        self.beginEditing()
        let defaultColor = UIColor.black
        self.enumerateAttribute(.foregroundColor, in: NSRange(location: 0, length: self.length)) { (value, range, _) in
            if let oldColor = value as? UIColor, oldColor == defaultColor {
                self.addAttribute(.foregroundColor, value: newColor, range: range)
            }
        }
        self.endEditing()
    }

    func trimmingTrailingNewlinesAndWhitespaces() -> NSMutableAttributedString {
        let invertedSet = CharacterSet.whitespacesAndNewlines.inverted

        let range = (self.string as NSString).rangeOfCharacter(from: invertedSet, options: .backwards)
        let length = range.location == NSNotFound ? 0 : NSMaxRange(range)
        var abc = NSMutableAttributedString(attributedString: self.attributedSubstring(from: NSRange(location: 0, length: length)))
        abc = (abc.attributedStringWithResizedImages(with: 20) as? NSMutableAttributedString)!
        return NSMutableAttributedString(attributedString: self.attributedSubstring(from: NSRange(location: 0, length: length)))

    }

    func trimmingTrailingNewlines() -> NSMutableAttributedString {
        let invertedSet = CharacterSet.whitespacesAndNewlines.subtracting(CharacterSet.whitespaces).inverted

        let range = (self.string as NSString).rangeOfCharacter(from: invertedSet, options: .backwards)
        let length = range.location == NSNotFound ? 0 : NSMaxRange(range)

        return NSMutableAttributedString(attributedString: self.attributedSubstring(from: NSRange(location: 0, length: length)))
    }
}
