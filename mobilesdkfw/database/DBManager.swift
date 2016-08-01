//
//  DBManager.swift
//  mobilesdkfw
//
//  Created by Blank, Gal (Contractor) on 7/19/16.
//  Copyright © 2016 PeopleLinx. All rights reserved.
//

import UIKit
import sqlite3


public class DBManager: NSObject {
    
    public static let sharedInstance = DBManager()
    
    var  databaseFullPath:String = ""
    var  dbname:NSString = ""
    var affectedRows:Int32 = 0
    var documentsDirectory:NSString = ""
    var arraysmatrix:NSMutableDictionary = NSMutableDictionary()
    var currentIndexMatrix:NSMutableDictionary = NSMutableDictionary()
    var databaseQueue:dispatch_queue_t? = nil
    var bundleDatabaseVersion = 0
    var lastInsertedRowID:CLongLong = 0
    
    var currentMatrixIndex = 0
    
    public override init() {
        super.init()
        // Notes: So on the very first install the DB will be copied from the app bundle to
        // the NSDocumentDirectory. The version of the data will be set in the info.plist
        // for the data in the bundle (regroupd-bundle-db-version:1). The NSUserDefaults will be
        // updated with a value (regroupd-install-db-version:1).
        //
        // The code logic will be such that if the install DB version is the same as the
        // bundle DB version, then do nothing.
        //
        // If the bundle DB version is greater than the install DB version, then delete the
        // install version and then copy the bundle to the install location and update the
        // NSUderDefaults with the install DB version.
        //
        // The bundle DB version should never be less than the install version.
        //
        // Since if the user deletes the app, both NSDocumentDirectory & NSUserDefaults are wiped.
        // App updates do not wipe the NSUserDefaults (or the NSDocumentDirectory).
        databaseQueue = dispatch_queue_create("com.gb.app.dbqueue", DISPATCH_QUEUE_SERIAL)
        
        dbname = NSBundle.mainBundle().infoDictionary!["databasename"] as! String
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let docPath = paths[0]
        databaseFullPath += "\(docPath)/" + "\(dbname)"
        print(databaseFullPath)
        let bundleDBVersionString = NSBundle.mainBundle().infoDictionary!["BundleDBVersion"] as? String
        if(bundleDBVersionString != nil){
            bundleDatabaseVersion = Int(bundleDBVersionString!)!
        }
        print("BundleDBVersion: \(bundleDBVersionString)")
        
        // Get Install DB version.
        var installDatabaseVersion = 0;
        let installDatabaseVersionString = NSUserDefaults.standardUserDefaults().objectForKey("kDB_BUNDLE_VERSION_KEY") as? String
        if(installDatabaseVersionString != nil)
        {
            installDatabaseVersion = Int(installDatabaseVersionString!)!
        }
        
        
        if(hasDatabaseBeenInstalled() == false)
        {
            // Copy the DB over now.
            copyDatabaseIntoDocumentsDirectory()
            
            // Finally, update the install version with the intalled bundle version.
        }
        else
        {
            print("DB is present. Determine if we need to upgrade DB or not.")
            
            // Determine if we need to upgrade or not.
            if(bundleDatabaseVersion > installDatabaseVersion)
            {
                print("Upgrade DB Flow")
                if (NSFileManager.defaultManager().isDeletableFileAtPath(databaseFullPath) == true)
                {
                    do{
                        try NSFileManager.defaultManager().removeItemAtPath(databaseFullPath)
                        copyDatabaseIntoDocumentsDirectory()
                    }
                    catch{
                        print("failed to remove db")
                    }
                }
            }
            else
            {
                print("Both bundleDatabaseVersion and installDatabaseVersion are the same: \(installDatabaseVersion) Skipping DB copy.")
            }
        }
    }
    
    public func hasDatabaseBeenInstalled() -> Bool
    {
        var isinstalled = false
        if(databaseFullPath.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0){
            isinstalled = NSFileManager.defaultManager().fileExistsAtPath(databaseFullPath)
            if(isinstalled == true){
                print("db exists at : \(databaseFullPath)")
            }
        }
        return isinstalled
    }
    
    public func copyDatabaseIntoDocumentsDirectory()
    {
        var bForceCopy = false
        #if (TARGET_IPHONE_SIMULATOR)
            bForceCopy = true
        #endif
        if(NSFileManager.defaultManager().fileExistsAtPath(databaseFullPath) == false || bForceCopy == true){
            let dbnameWithoutSyffix = dbname.stringByDeletingPathExtension
            let dbextension = dbname.pathExtension
            let dbFullPath = NSBundle.mainBundle().pathForResource(dbnameWithoutSyffix, ofType: dbextension)
            do{
                try NSFileManager.defaultManager().copyItemAtPath(dbFullPath!, toPath: databaseFullPath)
                print("db installed from main bundle")
                NSUserDefaults.standardUserDefaults().setInteger(bundleDatabaseVersion, forKey: "kDB_BUNDLE_VERSION_KEY")
                NSUserDefaults.standardUserDefaults().synchronize()
            }
            catch{
                print("failed to install db")
            }
        }
    }
    
    public func deleteAllDataFromDB()
    {
        let query = "delete from person"
        //[self executeQuery:query];
        print("Deleted the whole DB")
    }
    
    public func runQuery(query:String, isQueryExecutable:Bool) -> Bool{
        
        
        var didQueryRun = false
        var sqlite3Database:COpaquePointer = nil
        var arrResults:NSMutableArray = NSMutableArray()
        print(databaseFullPath)
        var openDatabaseResult = SQLITE_ERROR
        openDatabaseResult = sqlite3_open(databaseFullPath, &sqlite3Database)
        if(openDatabaseResult == SQLITE_OK){
            var compiledStatement: COpaquePointer = nil
            if(sqlite3_prepare_v2(sqlite3Database, query, -1, &compiledStatement, nil) != SQLITE_OK){
                let errmsg = String.fromCString(sqlite3_errmsg(sqlite3Database))
                print("error preparing insert: \(errmsg)")
                return false
            }
            
            if (isQueryExecutable == false){
                // In this case data must be loaded from the database.
                while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                    var rowValuesMap = NSMutableDictionary()
                    // Get the total number of columns.
                    let totalColumns = sqlite3_column_count(compiledStatement)
                    for i in 0..<totalColumns{
                        let dColumnNameAsChars = sqlite3_column_name(compiledStatement, i)
                        let strColumnName = NSString(UTF8String: dColumnNameAsChars)
                        // Convert the column data to text (characters).
                        let dbDataAsChars = sqlite3_column_text(compiledStatement, i)
                        var columnValue = ""
                        // If there are contents in the currenct column (field) then add them to the current row array.
                        if (dbDataAsChars != nil) {
                            // Convert the characters to string.
                            columnValue = String(dbDataAsChars)
                        }
                        // Keep the current column name.
                        rowValuesMap.setObject(columnValue, forKey: strColumnName!)
                    }
                    arrResults.addObject(rowValuesMap)
                }
                arraysmatrix.setObject(arrResults, forKey: currentMatrixIndex)
                currentIndexMatrix.setObject(0, forKey: currentMatrixIndex)
            }
            else{
                // This is the case of an executable query (insert, update, ...).
                // Execute the query.
                let executeQueryResults = sqlite3_step(compiledStatement);
                if (executeQueryResults == SQLITE_DONE) {
                    // Keep the affected rows.
                    affectedRows = sqlite3_changes(sqlite3Database)
                    
                    // Keep the last inserted row ID.
                    lastInsertedRowID = sqlite3_last_insert_rowid(sqlite3Database);
                    //NSLog(@"LAST ROWID: %lu",self.lastInsertedRowID);
                }
                else {
                    // If could not execute the query show the error message on the debugger.
                    print("Error executing statement \(sqlite3_errmsg(sqlite3Database))")
                }
            }
            
            // Release the compiled statement from memory.
            sqlite3_finalize(compiledStatement);
            // Close the database.
            sqlite3_close(sqlite3Database);
            
            // mark the query as run
            didQueryRun = true
        }
        else{
             print("Error openning db \(sqlite3_errmsg(sqlite3Database))")
        }
        
        
        return didQueryRun
    }
    
    
    public func rowCountForIndex(matrixIndex:Int) -> Int
     {
        let tempArr = arraysmatrix.objectForKey(matrixIndex)
        if(tempArr != nil){
            return tempArr!.count
        }
        return 0;
     }
    
    public func hasDataForIndex(matrixIndex:Int) -> Bool
    {
     let tempArr = arraysmatrix.objectForKey(matrixIndex)
        if(tempArr == nil){
            return false
        }
     let currentIndexForThisArray = currentIndexMatrix.objectForKey(matrixIndex) as! Int
        if(currentIndexForThisArray < tempArr!.count){
            return true
        }
      arraysmatrix.removeObjectForKey(matrixIndex)
        currentIndexMatrix.removeObjectForKey(matrixIndex)
        
     return false;
     }
    
    
    public func nextForIndex(matrixIndex:Int) -> NSMutableDictionary?
     {
      let tempArr = arraysmatrix.objectForKey(matrixIndex)
    var currentIndexForThisArray = currentIndexMatrix.objectForKey(matrixIndex) as! Int
     if(currentIndexForThisArray < tempArr!.count){
    let valuesMap = tempArr![currentIndexForThisArray] as! NSMutableDictionary
     currentIndexForThisArray += 1
     currentIndexMatrix.setObject(currentIndexForThisArray, forKey: matrixIndex)    //(currentIndexForThisArray forKey:matrixIndex)
     return valuesMap;
     }
     
        arraysmatrix.removeObjectForKey(matrixIndex)
        currentIndexMatrix.removeObjectForKey(matrixIndex)
     
     return nil
     }
     
    public func loadDataFromDB(query:String) -> Int
    {
        if(query.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0){
            dispatch_sync(databaseQueue!, { 
                self.currentMatrixIndex += 1
                self.runQuery(query, isQueryExecutable: false)
            })
        }
        
        return currentMatrixIndex
    }
    
    
    public func executeQuery(query:String) -> Bool
    {
        var isQueryExecuted = false
        if(query.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0){
            dispatch_sync(databaseQueue!, {
                isQueryExecuted = self.runQuery(query, isQueryExecutable: true)
            })
        }
        
        return isQueryExecuted
    }
    
}
