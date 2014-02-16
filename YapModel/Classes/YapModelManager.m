//
//  YapDatabaseManager.m
//  YapModel
//
//  Created by Francis Chong on 2/15/14.
//  Copyright (c) 2014 Ignition Soft. All rights reserved.
//

#import "YapModelManager.h"

NSString* const YapModelManagerReadTransactionKey       = @"YapModelManagerReadTransactionKey";
NSString* const YapModelManagerReadWriteTransactionKey  = @"YapModelManagerReadWriteTransactionKey";

@implementation YapModelManager

@synthesize databaseName = _databaseName;
@synthesize database = _database;
@synthesize connection = _connection;

+ (instancetype)sharedManager
{
    static YapModelManager *singleton;
    static dispatch_once_t singletonToken;
    dispatch_once(&singletonToken, ^{
        singleton = [[self alloc] init];
    });
    return singleton;
}

-(YapDatabase*) database
{
    if (_database) {
        return _database;
    }
    
    _database = [[YapDatabase alloc] initWithPath:[self sqliteStorePath]];
    return _database;
}

-(YapDatabaseConnection*) connection
{
    if (_connection) {
        return _connection;
    }

    _connection = [[self database] newConnection];
    return _connection;
}

- (void) setDatabase:(YapDatabase *)database
{
    _database = database;
    _connection = nil;
}

- (NSString *)databaseName
{
   if (_databaseName != nil) return _databaseName;
   
   _databaseName = [[[self appName] stringByAppendingString:@".sqlite"] copy];
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

#pragma mark - Private

- (NSString *)appName {
    return [[[NSBundle bundleForClass:[self class]] infoDictionary] objectForKey:@"CFBundleName"];
}

- (NSString*) sqliteStorePath {
    NSURL *directory = [self isOSX] ? self.applicationSupportDirectory : self.applicationDocumentsDirectory;
    NSString *databaseDir = [[directory path] stringByAppendingPathComponent:[self databaseName]];

    [self createApplicationSupportDirIfNeeded:directory];
    return databaseDir;
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
