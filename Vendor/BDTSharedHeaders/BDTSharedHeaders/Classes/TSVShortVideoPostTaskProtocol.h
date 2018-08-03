//
//  TSVShortVideoPostTaskProtocol.h
//  Pods
//
//  Created by 王双华 on 2017/11/23.
//

#ifndef TSVShortVideoPostTaskProtocol_h
#define TSVShortVideoPostTaskProtocol_h

#import <Foundation/Foundation.h>

//小视频concernID，先这么写着，到时候改&沉库
#define kTTShortVideoConcernID        @"6488581776355625485"

typedef NS_ENUM(NSUInteger, TTForumPostThreadTaskStatus) {
    TTForumPostThreadTaskStatusPosting = 0,
    TTForumPostThreadTaskStatusFailed = 1,
    TTForumPostThreadTaskStatusSucceed = 2,
};

@protocol TSVShortVideoPostTaskProtocol<NSObject>

@property (nonatomic, assign, readonly) int64_t fakeID;
@property (nonatomic, copy, readonly) NSString * concernID;
@property (nonatomic, copy, readonly) NSString * categoryID;

@property(nonatomic, assign, readonly) TTForumPostThreadTaskStatus status;
@property(nonatomic, assign, readonly) CGFloat uploadProgress;
@property(nonatomic, strong, readonly) UIImage *shortVideoCoverImage;
///头条小视频活动concernID 和concernID 不同，从活动页发小视频时，tsvActivityConcernID表示该活动页所在关心主页的concernID
@property(nonatomic, copy, readonly) NSString *tsvActivityConcernID;
///被挑战的小视频的groupID
@property(nonatomic, copy, readonly) NSString *challengeGroupID;

@property(nonatomic, copy, readonly)NSDictionary * extraTrack;
@property(nonatomic, assign, readonly) BOOL shouldShowRedPacket;
@property(nonatomic, copy, readonly) NSDictionary *pkStatus;

- (BOOL)isShortVideo;
- (BOOL)shouldInsertToShortVideoTab;
- (BOOL)isFromConcernHomepage;

@end
#endif /* TSVShortVideoPostTaskProtocol_h */
