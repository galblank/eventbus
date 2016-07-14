//
//  DBManager.m
//  Gal Blank.com
//
//  Created by Gal Blank on 12/19/14.
//  Copyright (c) 2014 Gal Blank. All rights reserved.
//

#import "DBManager.h"
#import <sqlite3.h>

@implementation DBManager

@synthesize lastInsertedRowID;


static DBManager *sharedDBSingletonDelegate = nil;


+ (DBManager *)sharedInstance {
    @synchronized(self) {
        if (sharedDBSingletonDelegate == nil) {
            [[self alloc] init]; // assignment not done here
            
        }
    }
    return sharedDBSingletonDelegate;
}



+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedDBSingletonDelegate == nil) {
            sharedDBSingletonDelegate = [super allocWithZone:zone];
            // assignment and return on first allocation
            return sharedDBSingletonDelegate;
        }
    }
    // on subsequent allocation attempts return nil
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

-(id)init
{
    
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
    databaseQueue = dispatch_queue_create(DB_QUEUE_NAME, 0);
    
    
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    
    
    dbname = [infoDict objectForKey:@"databasename"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsPath = [paths objectAtIndex:0];
    databaseFullPath = [docsPath stringByAppendingPathComponent:dbname];
    
    currentMatrixIndex = 0;
    currentIndexMatrix = [[NSMutableDictionary alloc] init];
    arraysmatrix = [[NSMutableDictionary alloc] init];
    // Get Bundle DB version.
    long bundleDatabaseVersion = 0;
    NSString *bundleDBVersionString = [infoDict objectForKey:@"BundleDBVersion"];
    
    if(bundleDBVersionString)
    {
        bundleDatabaseVersion = [bundleDBVersionString integerValue];
    }
    NSLog(@"bundleDBVersionString: %@", bundleDBVersionString);
    
    // Get Install DB version.
    long installDatabaseVersion = 0;
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *installDatabaseVersionString = [standardUserDefaults objectForKey:DB_BUNDLE_VERSION_KEY];
    if(installDatabaseVersionString)
    {
        installDatabaseVersion = [installDatabaseVersionString integerValue];
    }
    NSLog(@"installDatabaseVersionString: %@", installDatabaseVersionString==nil?@"Not Yet Saved":installDatabaseVersionString);
    
    if([self hasDatabaseBeenInstalled] == NO)
    {
        // Copy the DB over now.
        [self copyDatabaseIntoDocumentsDirectory];
        
        // Finally, update the install version with the intalled bundle version.
        NSString *versionString = [NSString stringWithFormat:@"%ld", (long)bundleDatabaseVersion];
        [standardUserDefaults setObject:versionString forKey:DB_BUNDLE_VERSION_KEY];
        [standardUserDefaults synchronize];
    }
    else
    {
        NSLog(@"DB is present. Determine if we need to upgrade DB or not.");
        
        // Determine if we need to upgrade or not.
        if(bundleDatabaseVersion > installDatabaseVersion)
        {
            NSLog(@"Upgrade DB Flow");
            
            // Delete the existing one.
            BOOL success = NO;
            NSError *error;
            
            if ([[NSFileManager defaultManager] isDeletableFileAtPath:databaseFullPath])
            {
                success = [[NSFileManager defaultManager] removeItemAtPath:databaseFullPath error:&error];
                
                if(success == NO)
                {
                    NSLog(@"Error removing file: %@", error.localizedDescription);
                }
            }
            else
            {
                NSLog(@"{WARNING} Unable to delete file at path: %@", databaseFullPath);
            }
            
            
            if(success == YES)
            {
                // Now copy over the new one.
                [self copyDatabaseIntoDocumentsDirectory];
                
                
                // Finally, update the install version with the intalled bundle version.
                NSString *versionString = [NSString stringWithFormat:@"%ld", (long)bundleDatabaseVersion];
                [standardUserDefaults setObject:versionString forKey:DB_BUNDLE_VERSION_KEY];
                [standardUserDefaults synchronize];
            }
        }
        else
        {
            NSLog(@"Both bundleDatabaseVersion and installDatabaseVersion are the same: %ld Skipping DB copy.", installDatabaseVersion);
            NSLog(@"ALL GOOD with DB - No Update Needed");
        }
    }
    
    return self;
}


- (BOOL)hasDatabaseBeenInstalled
{
    BOOL hasBeenInstalled = NO;
    
    if(databaseFullPath && databaseFullPath.length > 0)
    {
        hasBeenInstalled = [[NSFileManager defaultManager] fileExistsAtPath:databaseFullPath];
        if(hasBeenInstalled){
            NSLog(@"DB Exists at path :%@",databaseFullPath);
        }
        else{
            NSLog(@"hasDatabaseBeenInstalled: NO, so just copying the DB from bundle now.");
        }
    };
    
    return(hasBeenInstalled);
}



-(void)copyDatabaseIntoDocumentsDirectory{
    // Check if the database file exists in the documents directory.
    BOOL bForceCopy = NO;
#if (TARGET_IPHONE_SIMULATOR)
    bForceCopy = YES;
#endif
    if (![[NSFileManager defaultManager] fileExistsAtPath:databaseFullPath] || bForceCopy) {
        // The database file does not exist in the documents directory, so copy it from the main bundle now.
        NSError *error;
        NSString * dbnamenosuffix = [dbname stringByDeletingPathExtension];
        NSString * dbextension = [dbname pathExtension];
        NSString *fullDBFilePath = [[NSBundle mainBundle] pathForResource:dbnamenosuffix ofType:dbextension];
        BOOL bCopiedFile = [[NSFileManager defaultManager] copyItemAtPath:fullDBFilePath toPath:databaseFullPath error:&error];
        if(bCopiedFile == NO)
        {
            NSLog(@"Failed to copy DB file from %@",fullDBFilePath);
        }
        else
        {
            NSLog(@"DB file is installed from main bundle.");
        }
    }
}

-(void)deleteAllDataFromDB
{
    NSString *query = @"delete from person";
    [self executeQuery:query];
    NSLog(@"Deleted the whole DB");
}

-(BOOL)runQuery:(const char *)query isQueryExecutable:(BOOL)queryExecutable{

    BOOL didQueryRun = NO;
    
    // Create a sqlite object.
    sqlite3 *sqlite3Database = nil;

    NSMutableArray *    arrResults = [[NSMutableArray alloc] init];
    int openDatabaseResult = SQLITE_ERROR;
    // Open the database.
    openDatabaseResult = sqlite3_open([databaseFullPath UTF8String], &sqlite3Database);
    if(openDatabaseResult == SQLITE_OK) {
        // Declare a sqlite3_stmt object in which will be stored the query after having been compiled into a SQLite statement.
        sqlite3_stmt *compiledStatement;
        //sqlite3_busy_timeout(sqlite3Database, 500);
        // Load all data from database to memory.
        BOOL prepareStatementResult = sqlite3_prepare_v2(sqlite3Database, query, -1, &compiledStatement, NULL);
        if(prepareStatementResult == SQLITE_OK) {
            // Check if the query is non-executable.
            if (!queryExecutable){
                // In this case data must be loaded from the database.
                
                // Loop through the results and add them to the results array row by row.
                while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                    // Initialize the mutable array that will contain the data of a fetched row.
                    NSMutableDictionary * rowValuesMap = [[NSMutableDictionary alloc] init];
                    // Get the total number of columns.
                    int totalColumns = sqlite3_column_count(compiledStatement);
                    
                    // Go through all columns and fetch each column data.
                    for (int i=0; i<totalColumns; i++){
                        
                        char * dColumnNameAsChars = (char *)sqlite3_column_name(compiledStatement, i);
                        NSString * columnName = [NSString stringWithUTF8String:dColumnNameAsChars];
                        // Convert the column data to text (characters).
                        char *dbDataAsChars = (char *)sqlite3_column_text(compiledStatement, i);
                        NSString * columnValue = @"";
                        // If there are contents in the currenct column (field) then add them to the current row array.
                        if (dbDataAsChars != NULL) {
                            // Convert the characters to string.
                            columnValue = [NSString  stringWithUTF8String:dbDataAsChars];
                        }
                        // Keep the current column name.
                        [rowValuesMap setObject:columnValue forKey:columnName];
                        
                    }
                    
                    [arrResults addObject:rowValuesMap];
//                    NSLog(@"%@",arrResults);
                }
                [arraysmatrix setObject:arrResults forKey:[NSNumber numberWithInt:currentMatrixIndex]];
                [currentIndexMatrix setObject:[NSNumber numberWithInt:0] forKey:[NSNumber numberWithInt:currentMatrixIndex]];
            }
            else {
                // This is the case of an executable query (insert, update, ...).
                // Execute the query.
                int executeQueryResults = sqlite3_step(compiledStatement);
                if (executeQueryResults == SQLITE_DONE) {
                    // Keep the affected rows.
                    affectedRows = sqlite3_changes(sqlite3Database);
                    
                    // Keep the last inserted row ID.
                    lastInsertedRowID = sqlite3_last_insert_rowid(sqlite3Database);
                    //NSLog(@"LAST ROWID: %lu",self.lastInsertedRowID);
                }
                else {
                    // If could not execute the query show the error message on the debugger.
                    NSLog(@"DB Error: %s", sqlite3_errmsg(sqlite3Database));
                }
            }
        }
        else {
            // In the database cannot be opened then show the error message on the debugger.
            
            NSLog(@"%s for query %s", sqlite3_errmsg(sqlite3Database),query);
        }
        
        // Release the compiled statement from memory.
        sqlite3_finalize(compiledStatement);
        // Close the database.
        sqlite3_close(sqlite3Database);
        
        // mark the query as run
        didQueryRun = YES;
    }
    else {
        // In the database cannot be opened then show the error message on the debugger.
        NSLog(@"%s", sqlite3_errmsg(sqlite3Database));
        
         // mark the query as not having ran
        didQueryRun = NO;
    }
    
    return didQueryRun;
}

-(int)rowCountForIndex:(int)matrixIndex
{
    NSMutableArray * tempArr = [arraysmatrix objectForKey:[NSNumber numberWithInt:matrixIndex]];
    if(tempArr){
        return tempArr.count;
    }
    return 0;
}

-(BOOL)hasDataForIndex:(int)matrixIndex
{
    NSMutableArray * tempArr = [arraysmatrix objectForKey:[NSNumber numberWithInt:matrixIndex]];
    NSNumber * currentIndexForThisArray = [currentIndexMatrix objectForKey:[NSNumber numberWithInt:matrixIndex]];
    if(currentIndexForThisArray.intValue  < tempArr.count){
        return YES;
    }
    [arraysmatrix removeObjectForKey:[NSNumber numberWithInt:matrixIndex]];
    [currentIndexMatrix removeObjectForKey:[NSNumber numberWithInt:matrixIndex]];
    return NO;
}

-(NSMutableDictionary*)nextForIndex:(int)matrixIndex
{
    NSMutableArray * tempArr = [arraysmatrix objectForKey:[NSNumber numberWithInt:matrixIndex]];
    NSNumber * currentIndexForThisArray = [currentIndexMatrix objectForKey:[NSNumber numberWithInt:matrixIndex]];
    if(currentIndexForThisArray.intValue  < tempArr.count){
        NSMutableDictionary * valuesMap = [tempArr objectAtIndex:currentIndexForThisArray.intValue];
        currentIndexForThisArray = [NSNumber numberWithInt:currentIndexForThisArray.intValue + 1];
        [currentIndexMatrix setObject:currentIndexForThisArray forKey:[NSNumber numberWithInt:matrixIndex]];
        return valuesMap;
    }
    
    [arraysmatrix removeObjectForKey:[NSNumber numberWithInt:matrixIndex]];
    [currentIndexMatrix removeObjectForKey:[NSNumber numberWithInt:matrixIndex]];
    
    return nil;
}


-(int)loadDataFromDB:(NSString *)query
{
    //NSLog(@"[DBManager] -loadDataFromDB-");
    
    if((query) && ([query isKindOfClass:[NSString class]] == YES)){
        dispatch_sync(databaseQueue, ^{
            currentMatrixIndex += 1;
            [self runQuery:[query UTF8String] isQueryExecutable:NO];
        });
    }
    else
    {
        NSLog(@"{WARNING} loadDataFromDB query is missing or not a string.");
    }
    
    return currentMatrixIndex;
}


-(BOOL)executeQuery:(NSString *)query
{
     __block BOOL isQueryExecuted = NO;
   
    if((query) && ([query isKindOfClass:[NSString class]] == YES)){
        dispatch_sync(databaseQueue, ^{
            //NSLog(@"execute query: %@",query);
            isQueryExecuted = [self runQuery:[query UTF8String] isQueryExecutable:YES];
            //NSLog(@"execute over: %@",query);
        });
    }
    else
    {
        NSLog(@"{WARNING} executeQuery query is missing or not a string.");
    }
    
    return isQueryExecuted;
}







@end
