//
//  IO.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 1/5/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation

//////////////////////////////////////////////////////////////////////////////////////////
// Import
//////////////////////////////////////////////////////////////////////////////////////////

class FileIO
{
    var fileManager:NSFileManager
    
    init()
    {
        fileManager = NSFileManager.defaultManager()
    }
    
    func importStringFromFileInBundle(fileName:String, fileExtension:String) -> String?
    {
        var stringContents:String?
        
        if let filePath = filePathInBundle(fileName, fileExtension:fileExtension)
        {
            stringContents = stringContentsFromFilePath(filePath)
        }
        
        return stringContents
    }
    
    func importStringFromFileInDocs(fileName:String, fileExtension:String, pathFromDocs:String?) -> String?
    {
        var stringContents:String?
        
        let filePath = filePathInDocs(fileName, fileExtension:fileExtension, pathFromDocs:pathFromDocs)
        stringContents = stringContentsFromFilePath(filePath)
        
        return stringContents
    }
    
    func exportToFileInDocs(fileName:String, fileExtension:String, pathFromDocs:String?, contents:String)
    {
        let filePath = filePathInDocs(fileName, fileExtension:fileExtension, pathFromDocs:pathFromDocs)
        
        if let pathFromDocs = pathFromDocs
        {
            let intermediatePath = filePathForDirectoryInDocs(pathFromDocs)
            if !fileManager.fileExistsAtPath(intermediatePath)
            {
                do
                {
                    try fileManager.createDirectoryAtPath(intermediatePath, withIntermediateDirectories:true, attributes:nil)
                }
                catch let error as NSError
                {
                    print("Could not create source directory due to error: \(error.localizedDescription)")
                }
            }
        }
        
        do
        {
            try contents.writeToFile(filePath, atomically:true, encoding:NSUTF8StringEncoding)
        }
        catch let error as NSError
        {
            print("Unable to write to model file named \(fileName): \(error.localizedDescription)")
        }
    }
    
    func removeFileInDocs(fileName:String, fileExtension:String, pathFromDocs:String?)
    {
        let filePath = filePathInDocs(fileName, fileExtension:fileExtension, pathFromDocs:pathFromDocs)
        
        do
        {
            try fileManager.removeItemAtPath(filePath)
        }
        catch let error as NSError
        {
            print("Unable to remove file: \(error.localizedDescription)")
        }
    }
    
    private func docsPath() -> String
    {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        return paths[0]
    }
    
    // Path from docs is the path from the root docs folder to the desired folder where the file is contained
    // Example: to get access to "Documents/Sources/Crypt000.map" you would use the following parameters:
        // fileName: "Crypt000"
        // fileExtension: "map"
        // pathFromDocs: "Sources"
    private func filePathInDocs(fileName:String, fileExtension:String, pathFromDocs:String?) -> String
    {
        let docs = docsPath()
        let intermediatePath = (pathFromDocs != nil) ? pathFromDocs! + "/" : ""
        return "\(docs)/\(intermediatePath)\(fileName).\(fileExtension)"
    }
    
    private func filePathForDirectoryInDocs(pathFromDocs:String) -> String
    {
        let docs = docsPath()
        return "\(docs)/\(pathFromDocs)"
    }
    
    private func filePathInBundle(fileName:String, fileExtension:String) -> String?
    {
        return NSBundle.mainBundle().pathForResource(fileName, ofType:fileExtension)
    }
    
    private func fileExistsInDocsWithName(name:String, fileExtension:String, pathFromDocs:String?) -> Bool
    {
        let path = filePathInDocs(name, fileExtension:fileExtension, pathFromDocs:pathFromDocs)
        return fileManager.fileExistsAtPath(path)
    }
    
    private func fileExistsInBundleWithName(name:String, fileExtension:String) -> Bool
    {
        if let _ = filePathInBundle(name, fileExtension:fileExtension)
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    private func stringContentsFromFilePath(filePath:String) -> String?
    {
        var stringContents:String?
        
        do
        {
            stringContents = try String(contentsOfFile:filePath, encoding:NSUTF8StringEncoding)
        }
        catch let error as NSError
        {
            print("error loading from path \(filePath)")
            print(error.localizedDescription)
        }
        
        return stringContents
    }
}