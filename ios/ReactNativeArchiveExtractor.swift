//
//  ReactNativeArchiveExtractor.swift
//  ReactNativeArchiveExtractor
//
//  Created by Icheol Shin on 3/8/24.
//

import Foundation
import SSZipArchive
import UIKit
import UnrarKit
import PLzmaSDK
import PDFKit

enum ExtractorError: Error {
    case ERR
    case EXT
    case SNF
    case DNF
    case DAE
}

extension ExtractorError: LocalizedError {
    public var errorDescription: String? {
        switch self {
            case .ERR:
                return NSLocalizedString("An error was occurred", comment: "")
            case .EXT:
                return NSLocalizedString("A problem occurred while extracting the archive", comment: "")
            case .SNF:
                return NSLocalizedString("Source file not found", comment: "")
            case .DNF:
                return NSLocalizedString("Destination directory not found", comment: "")
            case .DAE:
                return NSLocalizedString("File already exists", comment: "")
        }
    }
}

class ZipExtractor {
    static func extract(
        srcPath: String,
        dstPath: String,
        password: String? = nil
    ) throws {
        let encodedSrcPath = srcPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let encodedDstPath = dstPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        var error: NSError?
        let success: Bool = SSZipArchive.unzipFile(
            atPath: encodedSrcPath,
            toDestination: encodedDstPath,
            preserveAttributes: true,
            overwrite: false,
            password: password,
            error: &error,
            delegate: nil
        )
        
        if let error = error {
            throw error
        }

        if !success {
            throw ExtractorError.EXT
        }
    }

    static func isProtected(
        srcPath: String
    ) throws -> Bool {
        let encodedSrcPath = srcPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let isProtected = SSZipArchive.isFilePasswordProtected(atPath: encodedSrcPath)
        return isProtected
    }
}

class RarExtractor {
    static func extract(
        srcPath: String,
        dstPath: String,
        password: String? = nil
    ) throws {
        let encodedSrcPath = srcPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let encodedDstPath = dstPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let archive = try URKArchive(path: encodedSrcPath)
        
        if let password = password {
            archive.password = password
        }
        
        try archive.extractFiles(
            to: encodedDstPath,
            overwrite: false
        )
    }

    static func isProtected(
        srcPath: String
    ) throws -> Bool {
        let encodedSrcPath = srcPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let archive = try URKArchive(path: encodedSrcPath)
        return archive.isPasswordProtected()
    }
}

class SevenZipExtractor {
    static func extract(
        srcPath: String,
        dstPath: String,
        password: String? = nil
    ) throws {
        let encodedSrcPath = srcPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let encodedDstPath = dstPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        // 1. Create a source input stream for reading archive file content.
        //  1.1. Create a source input stream with the path to an archive file.
        let archivePath = try Path(encodedSrcPath)
        let archivePathInStream = try InStream(path: archivePath)

        //  1.2. Create a source input stream with the file content.
        // let archiveData = Data(...)
        // let archiveData = try Data(contentsOf:URL(string: srcPath)!)
        // let archiveDataInStream = try InStream(dataNoCopy: archiveData) // also available Data(dataCopy: Data)

        // 2. Create decoder with source input stream, type of archive and optional delegate.
        let decoder = try Decoder(stream: archivePathInStream, fileType: .sevenZ, delegate: nil)
        
        //  2.1. Optionaly provide the password to open/list/test/extract encrypted archive items.
        try decoder.setPassword(password)
        
        // let opened = try decoder.open()
        _ = try decoder.open()
        
        // 3. Select archive items for extracting or testing.
        //  3.1. Select all archive items.
        // let allArchiveItems = try decoder.items()
        // try decoder.items()
        
        //  3.2. Get the number of items, iterate items by index, filter and select items.
        // let numberOfArchiveItems = try decoder.count()
        // let selectedItemsDuringIteration = try ItemArray(capacity: numberOfArchiveItems)
        // let selectedItemsToStreams = try ItemOutStreamArray()
        // for itemIndex in 0..<numberOfArchiveItems {
        //     let item = try decoder.item(at: itemIndex)
        //     try selectedItemsDuringIteration.add(item: item)
        //     try selectedItemsToStreams.add(item: item, stream: OutStream()) // to memory stream
        // }
        
        // 4. Extract or test selected archive items. The extract process might be:
        //  4.1. Extract all items to a directory. In this case, you can skip the step #3.
        // let extracted = try decoder.extract(to: Path(dstPath))
        _ = try decoder.extract(to: Path(encodedDstPath))
        
        //  4.2. Extract selected items to a directory.
        // let extracted = try decoder.extract(items: selectedItemsDuringIteration, to: Path(destinationPath))
        
        //  4.3. Extract each item to a custom out-stream.
        //       The out-stream might be a file or memory. I.e. extract 'item #1' to a file stream, extract 'item #2' to a memory stream(then take extacted memory) and so on.
        // let extracted = try decoder.extract(itemsToStreams: selectedItemsToStreams)
    }

    // static func isProtected(
    //     _ srcPath: String
    // ) -> Bool {
    //     return false
    // }
}

class PdfExtractor {
    static func extractPage(
        page: PDFPage,
        dst: URL,
        quality: Int
    ) throws -> Void {
        let pageBoundingRect = page.bounds(for: .mediaBox)
        let image = page.thumbnail(
            of: CGSize(width: pageBoundingRect.width, height: pageBoundingRect.height),
            for: .mediaBox
        )
        
        guard let data = image.jpegData(compressionQuality: CGFloat(quality) / 100) else {
            throw ExtractorError.EXT
        }
        
        try data.write(to: dst)
    }

    static func extract(
        srcPath: String,
        dstPath: String,
        password: String? = nil
    ) throws -> Void {
        let encodedSrcPath = srcPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let encodedDstPath = dstPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        guard let srcUrl = URL(string: "file://\(encodedSrcPath)") else {
            throw ExtractorError.SNF
        }
        
        guard let dstUrl = URL(string: encodedDstPath) else {
            throw ExtractorError.DNF
        }
        
        guard let pdfDocument = PDFDocument(url: srcUrl) else {
            throw ExtractorError.SNF
        }
        
        if let password = password {
            pdfDocument.unlock(withPassword: password)
        }
        
        // check dupe
        for page in 0..<pdfDocument.pageCount {
            let filePath = "\(dstUrl.absoluteString)/\(page).jpg"
            
            if FileManager.default.fileExists(atPath: filePath) {
                throw ExtractorError.DAE
            }
        }
        
        // extract
        for page in 0..<pdfDocument.pageCount {
            let filePath = "file://\(dstUrl.absoluteString)/\(page).jpg"
            
            guard let pdfPage = pdfDocument.page(at: page) else {
                throw ExtractorError.EXT
            }
            
            guard let fileUrl = URL(string: filePath) else {
                throw ExtractorError.DNF
            }
            
            do {
                try extractPage(page: pdfPage, dst: fileUrl, quality: 100)
            } catch {
                throw error
            }
        }
    }

    static func isProtected(
        srcPath: String
    ) throws -> Bool {
        let encodedSrcPath = srcPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        guard let srcUrl = URL(string: "file://\(encodedSrcPath)") else {
            throw ExtractorError.SNF
        }
        
        guard let pdfDocument = PDFDocument(url: srcUrl) else {
            throw ExtractorError.SNF
        }
        
        if pdfDocument.isEncrypted {
            return true;
        }
        
        if pdfDocument.isLocked {
            return true;
        }
        
        return false;
    }
}

@objc(ReactNativeArchiveExtractor)
class ReactNativeArchiveExtractor: NSObject {

    @objc
    static func requiresMainQueueSetup() -> Bool {
        return true
    }

    @objc
    func getName() -> String {
        return "ReactNativeArchiveExtractor"
    }

    @objc
    func isProtectedZip(
        _ srcPath: String,
        resolve: RCTPromiseResolveBlock,
        reject: RCTPromiseRejectBlock
    ) {
        do {
            let isProtected = try ZipExtractor.isProtected(srcPath: srcPath)
            resolve(isProtected)
        } catch {
            reject("error", error.localizedDescription, error)
        }
    }
    
    @objc
    func extractZip(
        _ srcPath: String,
        dstPath: String,
        resolve: RCTPromiseResolveBlock,
        reject: RCTPromiseRejectBlock
    ) {
        do {
            try ZipExtractor.extract(srcPath: srcPath, dstPath: dstPath)
            resolve(nil)
        } catch {
            reject("error", error.localizedDescription, error)
        }
    }
    
    @objc
    func extractZipWithPassword(
        _ srcPath: String,
        dstPath: String,
        password: String? = nil,
        resolve: RCTPromiseResolveBlock,
        reject: RCTPromiseRejectBlock
    ) {
        do {
            try ZipExtractor.extract(srcPath: srcPath, dstPath: dstPath, password: password)
            resolve(nil)
        } catch {
            reject("error", error.localizedDescription, error)
        }
    }

    @objc
    func isProtectedRar(
        _ srcPath: String,
        resolve: RCTPromiseResolveBlock,
        reject: RCTPromiseRejectBlock
    ) {
        do {
            let isProtected = try RarExtractor.isProtected(srcPath: srcPath)
            resolve(isProtected)
        } catch {
            reject("error", error.localizedDescription, error)
        }
    }

    @objc
    func extractRar(
        _ srcPath: String,
        dstPath: String,
        resolve: RCTPromiseResolveBlock,
        reject: RCTPromiseRejectBlock
    ) {
        do {
            try RarExtractor.extract(srcPath: srcPath, dstPath: dstPath)
            resolve(nil)
        } catch {
            reject("error", error.localizedDescription, error)
        }
    }

    @objc
    func extractRarWithPassword(
        _ srcPath: String,
        dstPath: String,
        password: String? = nil,
        resolve: RCTPromiseResolveBlock,
        reject: RCTPromiseRejectBlock
    ) {
        do {
            try RarExtractor.extract(srcPath: srcPath, dstPath: dstPath, password: password)
            resolve(nil)
        } catch {
            reject("error", error.localizedDescription, error)
        }
    }

    // @objc
    // func isProtectedSenvenZip(
    //     _ srcPath: String,
    //     resolve: RCTPromiseResolveBlock,
    //     reject: RCTPromiseRejectBlock
    // ) {
    // }

    @objc
    func extractSevenZip(
        _ srcPath: String,
        dstPath: String,
        resolve: RCTPromiseResolveBlock,
        reject: RCTPromiseRejectBlock
    ) {
        do {
            try SevenZipExtractor.extract(srcPath: srcPath, dstPath: dstPath)
            resolve(nil)
        } catch {
            reject("error", error.localizedDescription, error)
        }
    }

    @objc
    func extractSevenZipWithPassword(
        _ srcPath: String,
        dstPath: String,
        password: String? = nil,
        resolve: RCTPromiseResolveBlock,
        reject: RCTPromiseRejectBlock
    ) {
        do {
            try SevenZipExtractor.extract(srcPath: srcPath, dstPath: dstPath, password: password)
            resolve(nil)
        } catch {
            reject("error", error.localizedDescription, error)
        }
    }

    @available(iOS 11.0, *)
    @objc
    func isProtectedPdf(
        _ srcPath: String,
        resolve: RCTPromiseResolveBlock,
        reject: RCTPromiseRejectBlock
    ) {
        do {
            let isProtected = try PdfExtractor.isProtected(srcPath: srcPath)
            resolve(isProtected)
        } catch {
            reject("error", error.localizedDescription, error)
        }
    }

    @available(iOS 11.0, *)
    @objc
    func extractPdf(
        _ srcPath: String,
        dstPath: String,
        resolve: RCTPromiseResolveBlock,
        reject: RCTPromiseRejectBlock
    ) {
        do {
            try PdfExtractor.extract(srcPath: srcPath, dstPath: dstPath)
            resolve(nil)
        } catch {
            reject("error", error.localizedDescription, error)
        }
    }

    @available(iOS 11.0, *)
    @objc
    func extractPdfWithPassword(
        _ srcPath: String,
        dstPath: String,
        password: String? = nil,
        resolve: RCTPromiseResolveBlock,
        reject: RCTPromiseRejectBlock
    ) {
        do {
            try PdfExtractor.extract(srcPath: srcPath, dstPath: dstPath, password: password)
            resolve(nil)
        } catch {
            reject("error", error.localizedDescription, error)
        }
    }
}
