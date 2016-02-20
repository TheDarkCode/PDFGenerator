//
//  PDFPageRenderable.swift
//  PDFGenerator
//
//  Created by Suguru Kishimoto on 2016/02/10.
//
//

import Foundation
import UIKit


protocol PDFPageRenderable {
    func renderPDFPage() throws
}

extension PDFPageRenderable {
    func renderPDFPage() throws {}
}

extension UIView: PDFPageRenderable {
    private func getPageSize() -> CGSize {
        if let scrollView = self as? UIScrollView {
            return scrollView.contentSize
        } else {
            return self.frame.size
        }
    }
    
    func renderPDFPage() throws {
        let size = getPageSize()
        guard size.width > 0 && size.height > 0 else {
            throw PDFGenerateError.ZeroSizeView(self)
        }
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        autoreleasepool {
            if let scrollView = self as? UIScrollView {
                let tmp = (offset: scrollView.contentOffset, frame: scrollView.frame)
                scrollView.contentOffset = CGPointZero
                scrollView.frame = CGRect(origin: CGPointZero, size: scrollView.contentSize)
                UIGraphicsBeginPDFPageWithInfo(scrollView.frame, nil)
                scrollView.layer.renderInContext(context)
                scrollView.frame = tmp.frame
                scrollView.contentOffset = tmp.offset
            } else {
                UIGraphicsBeginPDFPageWithInfo(self.bounds, nil)
                self.layer.renderInContext(context)
            }
        }
    }
}

extension UIImage: PDFPageRenderable {
    func renderPDFPage() throws {
        autoreleasepool {
            let bounds = CGRect(origin: CGPointZero, size: self.size)
            UIGraphicsBeginPDFPageWithInfo(bounds, nil)
            self.drawInRect(bounds)
        }
    }
}

protocol UIImageConvertible {
    func to_image() throws -> UIImage
}

extension String: UIImageConvertible {
    func to_image() throws -> UIImage{
        guard let image = UIImage(contentsOfFile: self) else{
            throw PDFGenerateError.ImageLoadFailed(self)
        }
        return image
    }
}

extension NSData: UIImageConvertible {
    func to_image() throws -> UIImage {
        guard let image = UIImage(data: self) else {
            throw PDFGenerateError.ImageLoadFailed(self)
        }
        return image
    }
}

extension CGImage: UIImageConvertible {
    func to_image() throws -> UIImage {
        return UIImage(CGImage: self)
    }
}