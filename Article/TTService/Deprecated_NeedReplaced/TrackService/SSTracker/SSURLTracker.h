//
//  SSURLTracker.h
//  Article
//
//  Created by Zhang Leonardo on 13-4-2.
//
//

#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>
#import "TTAdManager.h"

@interface TTAdBaseModel : JSONModel <TTAd>

@property (nonatomic, copy)NSString<Optional>* ad_id;
@property (nonatomic, copy)NSString<Optional>* log_extra;


- (instancetype)initWithAdId:(NSString*)ad_id logExtra:(NSString*)log_extra;

@end


@interface SSURLTracker : NSObject

+ (SSURLTracker *)shareURLTracker;

- (void)trackURL:(NSString *)urlString;
- (void)trackURLs:(NSArray/*<NSString>*/ *)URLs;

- (void)trackURL:(NSString *)urlString model:(TTAdBaseModel*)adBaseModel;
- (void)trackURLs:(NSArray *)URLs model:(TTAdBaseModel*)adBaseModel;
- (void)thirdMonitorUrls:(NSArray *)URLs;
- (void)thirdMonitorUrl:(NSString *)urlString;
@end


static inline void ssTrackURL (NSString * urlStr) {
    [[SSURLTracker shareURLTracker] trackURL:urlStr];
}
static inline void ssTrackURLs(NSArray *URLs) {
   [[SSURLTracker shareURLTracker] trackURLs:URLs];
}


static inline void ssTrackURLModel(NSString * urlStr, TTAdBaseModel* adBaseModel) {
    [[SSURLTracker shareURLTracker] trackURL:urlStr model:adBaseModel];
}
static inline void ssTrackURLsModel(NSArray *URLs, TTAdBaseModel* adBaseModel) {
    [[SSURLTracker shareURLTracker] trackURLs:URLs model:adBaseModel];
}
