//
//  Live.h
//  Article
//
//  Created by 杨心雨 on 16/8/17.
//
//

#import <Foundation/Foundation.h>
#import "ExploreOriginalData.h"

@class LiveMatch, LiveStar, LiveVideo, LiveSimple;

//typedef enum : NSUInteger {
//    TTLiveTypeStar = 1,
//    TTLiveTypeMatch = 2,
//    TTLiveTypeVideo = 3,
//} TTLiveType;

NS_ASSUME_NONNULL_BEGIN

@interface Live : ExploreOriginalData

@property (nullable, nonatomic, retain) NSNumber *liveId;
@property (nullable, nonatomic, retain) NSNumber *participated;
@property (nullable, nonatomic, retain) NSString *participatedSuffix;
@property (nullable, nonatomic, retain) NSNumber *status;
@property (nullable, nonatomic, retain) NSString *statusDisplay;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSNumber *type;
@property (nullable, nonatomic, retain) NSString *url;
@property (nullable, nonatomic, retain) NSNumber *followed;
@property (nullable, nonatomic, retain) NSNumber *showFollowed;
//@property (nullable, nonatomic, retain) NSDictionary *mediaInfo;
//@property (nullable, nonatomic, retain) NSString *guestDesc;
@property (nullable, nonatomic, retain) NSString *adCover;
@property (nullable, nonatomic, retain) NSNumber *adId;
@property (nullable, nonatomic, retain) NSString *logExtra;
@property (nullable, nonatomic, retain) NSString *source;
@property (nullable, nonatomic, retain) NSString *sourceAvatar;
@property (nullable, nonatomic, retain) NSString *sourceOpenUrl;
@property (nullable, nonatomic, retain) LiveMatch *match;
@property (nullable, nonatomic, retain) LiveStar *star;
@property (nullable, nonatomic, retain) LiveVideo *video;
@property (nullable, nonatomic, retain) LiveSimple *simple;
@property (nonatomic, readonly, nullable) NSString *picUrl;
@property (nonatomic, retain, nullable) NSArray        *filterWords;

- (void)updateWithDataContentObj:(NSDictionary * _Nullable)dataDict;

@end

NS_ASSUME_NONNULL_END
