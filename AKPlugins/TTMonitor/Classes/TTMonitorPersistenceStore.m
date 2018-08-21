//
//  TTMonitorPersistenceStore.m
//  TTMonitor
//
//  Created by ZhangLeonardo on 16/2/28.
//  Copyright © 2016年 ZhangLeonardo. All rights reserved.
//

#import "TTMonitorPersistenceStore.h"
#import "TTMonitorTrackItem.h"
#import "TTMonitorAggregateItem.h"
#import "TTMonitorStoreItem.h"


@interface TTMonitorPersistenceStore()

@end

@implementation TTMonitorPersistenceStore

#pragma mark -- file path

+ (NSString *)filePathForData:(NSString *)data
{
    NSString *filename = [NSString stringWithFormat:@"ttmonitor-%@.ttdata", data];
    return [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject]
            stringByAppendingPathComponent:filename];
}


+ (NSString *)trackersFilePath
{
    return [self filePathForData:@"trackers"];
}

+ (NSString *)storerFilePath
{
    return [self filePathForData:@"storer"];
}

+ (NSString *)counterFilePath
{
    return [self filePathForData:@"counter"];
}

+ (NSString *)timerFilePath
{
    return [self filePathForData:@"timer"];
}


#pragma mark -- file remove

+ (void)rmFileForPath:(NSString *)filePath
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSError *error;
        BOOL removed = [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
        if (!removed) {
        }
    }
}

#pragma mark -- archive

+ (void)archiveTrackItems:(NSArray<TTMonitorTrackItem *> *)tracks
{
    if (![tracks isKindOfClass:[NSArray class]] || [tracks count] == 0) {
        [self rmFileForPath:[self trackersFilePath]];
        return;
    }
    NSString *filePath = [self trackersFilePath];
    NSMutableArray *eventsQueueCopy = [NSMutableArray arrayWithArray:[tracks copy]];
    if (![NSKeyedArchiver archiveRootObject:eventsQueueCopy toFile:filePath]) {
    }
}

+ (void)archiveAggregateCounter:(TTMonitorAggregateItem *)item
{
    [self archiveAggregateItem:item filePath:[self counterFilePath]];
}

+ (void)archiveAggregateTimer:(TTMonitorAggregateItem *)item
{
    [self archiveAggregateItem:item filePath:[self timerFilePath]];
}

+ (void)archiveAggregateStorer:(TTMonitorStoreItem *)item
{
    NSString * filePath = [self storerFilePath];
    if (!item || ![item isKindOfClass:[TTMonitorStoreItem class]] || [item isEmpty]) {
        [self rmFileForPath:filePath];
    }
    TTMonitorAggregateItem * cItem = [item copy];
    if (![NSKeyedArchiver archiveRootObject:cItem toFile:filePath]) {
    }
}

+ (void)archiveAggregateItem:(TTMonitorAggregateItem *)item filePath:(NSString *)filePath
{
    if (!item || ![item isKindOfClass:[TTMonitorAggregateItem class]] || [item isEmpty]) {
        [self rmFileForPath:filePath];
    }
    TTMonitorAggregateItem * cItem = [item copy];
    if (![NSKeyedArchiver archiveRootObject:cItem toFile:filePath]) {
    }
}

#pragma mark -- unarchive

+ (id)unarchiveFromFile:(NSString *)filePath
{
    id unarchivedData = nil;
    @try {
        unarchivedData = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    }
    @catch (NSException *exception) {
        unarchivedData = nil;
    }
    
    [self rmFileForPath:filePath];
    return unarchivedData;
}


+ (NSArray<TTMonitorTrackItem *> *)unarchiveTrackers
{
    NSArray<TTMonitorTrackItem *> * array = (NSArray<TTMonitorTrackItem *> *)[self unarchiveFromFile:[self trackersFilePath]];
    return array;
}

+ (TTMonitorStoreItem *)unarchiveStorer
{
    TTMonitorStoreItem * item = [self unarchiveFromFile:[self storerFilePath]];
    return item;
}

+ (TTMonitorAggregateItem *)unarchiveCounter
{
    TTMonitorAggregateItem * item = [self unarchiveAggregateItemForFilePath:[self counterFilePath]];
    return item;
}

+ (TTMonitorAggregateItem *)unarchiveTimer
{
    TTMonitorAggregateItem * item = [self unarchiveAggregateItemForFilePath:[self timerFilePath]];
    return item;
}

+ (TTMonitorAggregateItem *)unarchiveAggregateItemForFilePath:(NSString *)filePath
{
    TTMonitorAggregateItem * item = [self unarchiveFromFile:filePath];
    return item;
}



@end
