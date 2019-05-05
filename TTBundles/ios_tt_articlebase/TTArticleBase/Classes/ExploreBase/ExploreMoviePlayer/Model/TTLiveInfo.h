//
//  TTLiveInfo.h
//  Article
//
//  Created by Dai Dongpeng on 6/1/16.
//
//

#import <JSONModel/JSONModel.h>
#import "ExploreVideoSP.h"

typedef NS_ENUM(NSUInteger, TTLiveStatus) {
    TTLiveStatusUnknow = 0,
    TTLiveStatusLiveEnd = 1,
    TTLiveStatusLiveWatting = 2,
    TTLiveStatusLiveing = 3,
    TTLiveStatusLiveFailed = 4,
    TTLiveStatusLivePulling = 5,
};

@interface TTLiveURLInfo : JSONModel
@property (nonatomic, copy) NSString *mainPlayURL;
@property (nonatomic, copy) NSString <Optional> *backupPlayURL;
@end

@interface TTLiveInfo : JSONModel

@property (nonatomic, strong) TTLiveURLInfo <Optional> *live0;
@property (nonatomic, strong) TTLiveURLInfo <Optional> *live1;
@property (nonatomic, strong) NSNumber <Optional> *backupStatus;
@property (nonatomic, strong) NSNumber <Optional> *status;
@property (nonatomic, strong) NSNumber <Optional> *liveStatus;
@property (nonatomic, strong) NSNumber <Optional> *startTime;
@property (nonatomic, strong) NSNumber <Optional> *endTime;

- (NSArray *)allURL;

@end
