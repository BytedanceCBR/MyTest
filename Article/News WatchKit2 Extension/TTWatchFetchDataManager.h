//
//  WatachFetchDataManager.h
//  Article
//
//  Created by 邱鑫玥 on 16/8/18.
//
//
#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface TTWatchFetchDataManager : NSObject

@property (assign,nonatomic) BOOL hasBackgroundRefreshData;

+ (instancetype)sharedInstance;

- (void)fetchDataWithCompleteBlock:(void (^)(NSData *data, NSError *error))completionBlock;

- (NSData *)getStoredData;

- (BOOL)shouldFetchRemoteData;

- (void)scheduleNextBackgroundRefresh;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
- (void)startBackgroundRefreshWithTask:(WKApplicationRefreshBackgroundTask *)task;
#pragma clang diagnostic pop

- (void)stopBackgroundRefresh;
@end
