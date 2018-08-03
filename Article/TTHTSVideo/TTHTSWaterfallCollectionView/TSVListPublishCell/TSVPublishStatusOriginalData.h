//
//  TSVPublishStatusOriginalData.h
//  Article
//
//  Created by 王双华 on 2017/11/24.
//

#import <TTPlatformUIModel/ExploreOriginalData.h>
#import "TSVShortVideoPostTaskProtocol.h"

/*
 concernID：活动页发布的小视频，有小视频tab时，concernID = kTTShortVideoConcernID，无小视频tab时，有关注频道时，concernID = 关注频道concernID，无关注频道，concernID = 推荐频道concernID；
 tsvActivityConcernID：活动页的concernID; 只有发布的视频，带了活动的hashtag时，才存在
 */

@interface TSVPublishStatusOriginalData : ExploreOriginalData

@property (nonatomic, strong, readonly) UIImage *coverImage;
@property (nonatomic, copy, readonly) NSString *concernID;
@property (nonatomic, copy, readonly) NSString *categoryID;

@property (nonatomic, assign, readonly) TTForumPostThreadTaskStatus status;
@property (nonatomic, assign, readonly) CGFloat uploadingProgress;
@property (nonatomic, assign, readonly) int64_t fakeID;
@property (nonatomic, copy, readonly) NSString *tsvActivityConcernID;
@property (nonatomic, copy, readonly) NSString *challengeGroupID;

- (void)updateWithTask:(id<TSVShortVideoPostTaskProtocol>)task;

- (NSDictionary *)dictForJSBridge;

@end
