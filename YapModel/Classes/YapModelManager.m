//
//  YapDatabaseManager.m
//  YapModel
//
//  Created by Francis Chong on 2/15/14.
//  Copyright (c) 2014 Ignition Soft. All rights reserved.
//

#import "YapModelManager.h"

NSString* const YapModelManagerSharedManagerKey         = @"YapModelManagerSharedManagerKey";
NSString* const YapModelManagerReadWriteTransactionKey  = @"YapModelManagerReadWriteTransactionKey";

@interface YapModelManager(){
    YapDatabaseConnection* _connection;
    YapDatabase* _database;
}
@end

@implementation YapModelManager

@synthesize databaseName = _databaseName;

+ (instancetype)sharedManager
{
    YapModelManager* manager = [[NSThread mainThread] threadDictionary][YapModelManagerSharedManagerKey];
    if (manager) {
        return manager;
    }

    manager = [[self alloc] init];
    [self setSharedManager:manager];
    return [[NSThread mainThread] threadDictionary][YapModelManagerSharedManagerKey];
}

+ (void)setSharedManager:(YapModelManager*)sharedManager
{
    if (sharedManager) {
        [[NSThread mainThread] threadDictionary][YapModelManagerSharedManagerKey] = sharedManager;
    } else {
        [[[NSThread mainThread] threadDictionary] removeObjectForKey:YapModelManagerSharedManagerKey];
    }
}

-(YapDatabase*) database
{
    if (!_database) {
        _database = [[YapDatabase alloc] initWithPath:[self sqliteStorePath]];
        if (!_database) {
            [NSException raise:NSInternalInconsistencyException format:@"cannot load database: %@", [self sqliteStorePath]];
        }
    }
    return _database;
}

-(void) dealloc {
    _connection = nil;
    _database = nil;
    _databaseName = nil;
}

-(YapDatabaseConnection*) connection
{
    if (!_connection) {
        _connection = [[self database] newConnection];
    }
    return _connection;
}

- (void) setDatabase:(YapDatabase *)database
{
    _database = database;
    _connection = nil;
}

- (NSString *)databaseName
{
    if (!_databaseName) {
        _databaseName = [[[self appName] stringByAppendingString:@".sqlite"] copy];
    }
    return _databaseName;
}

+ (YapDatabaseReadWriteTransaction*) transactionForCurrentThread
{
    return [[NSThread currentThread] threadDictionary][YapModelManagerReadWriteTransactionKey];
}

+(void) setTransactionForCurrentThread:(YapDatabaseReadWriteTransaction*)transaction
{
    if (transaction) {
        [[NSThread currentThread] threadDictionary][YapModelManagerReadWriteTransactionKey] = transaction;
    } else {
        [[[NSThread currentThread] threadDictionary] removeObjectForKey:YapModelManagerReadWriteTransactionKey];
    }
}

- (NSString*) sqliteStorePath {
    NSURL *directory = [self isOSX] ? self.applicationSupportDirectory : self.applicationDocumentsDirectory;
    NSString *databaseDir = [[directory path] stringByAppendingPathComponent:[self databaseName]];
    
    [self createApplicationSupportDirIfNeeded:directory];
    return databaseDir;
}

#pragma mark - Private

- (NSString *)appName {
    return [[[NSBundle bundleForClass:[self class]] infoDictionary] objectForKey:@"CFBundleName"];
}

- (BOOL)isOSX {
    if (NSClassFromString(@"UIDevice")) return NO;
    return YES;
}

- (void)createApplicationSupportDirIfNeeded:(NSURL *)url {
    if ([[NSFileManager defaultManager] fileExistsAtPath:url.absoluteString]) return;
    
    [[NSFileManager defaultManager] createDirectoryAtURL:url
                             withIntermediateDirectories:YES attributes:nil error:nil];
}

#pragma mark - Helpers

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                   inDomains:NSUserDomainMask] lastObject];
}

- (NSURL *)applicationSupportDirectory {
    return [[[[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory
                                                    inDomains:NSUserDomainMask] lastObject]
            URLByAppendingPathComponent:[self appName]];
}

@end
