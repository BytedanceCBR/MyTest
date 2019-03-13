//
//  TTURLTracker.h
//  Titan
//
//  Created by yin on 2017/5/11.
//  Copyright © 2017年 toutiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>

@class TTURLTrackerModel;
@interface TTURLTracker : NSObject

+ (TTURLTracker *)shareURLTracker;

- (void)trackURL:(NSString *)urlString;
- (void)trackURLs:(NSArray *)URLs;

- (void)trackURL:(NSString *)urlString model:(TTURLTrackerModel*)trackModel;
- (void)trackURLs:(NSArray *)URLs model:(TTURLTrackerModel*)trackModel;
- (void)thirdMonitorUrls:(NSArray *)URLs;
- (void)thirdMonitorUrl:(NSString *)urlString;

@end

static inline void ttTrackURL (NSString * urlStr) {
    [[TTURLTracker shareURLTracker] trackURL:urlStr];
}
static inline void ttTrackURLs(NSArray *URLs) {
    [[TTURLTracker shareURLTracker] trackURLs:URLs];
}


static inline void ttTrackURLModel(NSString * urlStr, TTURLTrackerModel* trackModel) {
    [[TTURLTracker shareURLTracker] trackURL:urlStr model:trackModel];
}
static inline void ttTrackURLsModel(NSArray *URLs, TTURLTrackerModel* trackModel) {
    [[TTURLTracker shareURLTracker] trackURLs:URLs model:trackModel];
}


@interface TTURLTrackerModel : JSONModel

@property (nonatomic, strong)NSString<Optional>* ad_id;
@property (nonatomic, strong)NSString<Optional>* log_extra;

- (instancetype)initWithAdId:(NSString*)ad_id logExtra:(NSString*)log_extra;

@end
