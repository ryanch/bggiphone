/*
 If you are using fmdb in your project, I'd love to hear about it.  Let me 
 know at gus@flyingmeat.com.
 
 In short, this is the MIT License.
 
 Copyright (c) 2008 Flying Meat Inc.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
*/ 


#import <Foundation/Foundation.h>
#import "sqlite3.h"
#import "FMResultSet.h"

@interface FMDatabase : NSObject 
{
	sqlite3*    db;
	NSString*   databasePath;
    BOOL        logsErrors;
    BOOL        crashOnErrors;
    BOOL        inUse;
    BOOL        inTransaction;
    BOOL        traceExecution;
    BOOL        checkedOut;
    int         busyRetryTimeout;
    BOOL        shouldCacheStatements;
    NSMutableDictionary *cachedStatements;
}


+ (id)databaseWithPath:(NSString*)inPath;
- (id)initWithPath:(NSString*)inPath;

- (BOOL) open;
- (void) close;
- (BOOL) goodConnection;
- (void) clearCachedStatements;

// encryption methods.  You need to have purchased the sqlite encryption extensions for these to work.
- (BOOL) setKey:(NSString*)key;
- (BOOL) rekey:(NSString*)key;


- (NSString *) databasePath;

- (NSString*) lastErrorMessage;

- (int) lastErrorCode;
- (BOOL) hadError;
- (sqlite_int64) lastInsertRowId;

- (sqlite3*) sqliteHandle;

- (BOOL) executeUpdate:(NSString *)sql arguments:(va_list)args;
- (BOOL) executeUpdate:(NSString*)sql, ...;

- (id) executeQuery:(NSString *)sql arguments:(va_list)args;
- (id) executeQuery:(NSString*)sql, ...;

- (BOOL) rollback;
- (BOOL) commit;
- (BOOL) beginTransaction;
- (BOOL) beginDeferredTransaction;

- (BOOL)logsErrors;
- (void)setLogsErrors:(BOOL)flag;

- (BOOL)crashOnErrors;
- (void)setCrashOnErrors:(BOOL)flag;

- (BOOL)inUse;
- (void)setInUse:(BOOL)value;

- (BOOL)inTransaction;
- (void)setInTransaction:(BOOL)flag;

- (BOOL)traceExecution;
- (void)setTraceExecution:(BOOL)flag;

- (BOOL)checkedOut;
- (void)setCheckedOut:(BOOL)flag;

- (int)busyRetryTimeout;
- (void)setBusyRetryTimeout:(int)newBusyRetryTimeout;

- (BOOL)shouldCacheStatements;
- (void)setShouldCacheStatements:(BOOL)value;

- (NSMutableDictionary *)cachedStatements;
- (void)setCachedStatements:(NSMutableDictionary *)value;


+ (NSString*) sqliteLibVersion;



@end

@interface FMStatement : NSObject {
    sqlite3_stmt *statement;
    NSString *query;
    long useCount;
}


- (void) close;
- (void) reset;

- (sqlite3_stmt *)statement;
- (void)setStatement:(sqlite3_stmt *)value;

- (NSString *)query;
- (void)setQuery:(NSString *)value;

- (long)useCount;
- (void)setUseCount:(long)value;



@end

