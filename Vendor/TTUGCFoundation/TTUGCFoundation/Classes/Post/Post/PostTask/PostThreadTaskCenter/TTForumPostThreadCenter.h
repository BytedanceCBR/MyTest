//
//  TTForumPostThreadCenter.h
//  Article
//
//  Created by 王霖 on 3/16/16.
//
//

#import <Foundation/Foundation.h>
#import "TTForumPostThreadTask.h"
#import "TTUGCDefine.h"
#import <TTUGCPostCenterProtocol.h>
#import <TTBaseLib/NSobject+TTAdditions.h>

@class TTForumPostImageCache;
@class TTRepostThreadModel;
@interface TTForumPostThreadCenter : NSObject<Singleton>

- (void)postThreadWithContent:(nullable NSString *)content
             contentRichSpans:(nullable NSString *)contentRichSpans
                 mentionUsers:(nullable NSString *)mentionUsers
              mentionConcerns:(nullable NSString *)mentionConcerns
                        title:(nullable NSString *)title
                  phoneNumber:(nullable NSString *)phoneNumber
                    fromWhere:(FRFromWhereType)fromWhere
                    concernID:(nonnull NSString *)concernID
                   categoryID:(nullable NSString *)categoryID
                   taskImages:(nullable NSArray<TTForumPostImageCacheTask *> *)taskImages
                  thumbImages:(nullable NSArray<UIImage *> *)thumbImages
                  needForward:(NSInteger)needForward
                         city:(nullable NSString *)city
                    detailPos:(nullable NSString *)detailPos
                    longitude:(CGFloat)longitude
                     latitude:(CGFloat)latitude
                        score:(CGFloat)score
                        refer:(NSUInteger)refer
             postUGCEnterFrom:(TTPostUGCEnterFrom)postUGCEnterFrom
                   extraTrack:(nullable NSDictionary *)extraTrack
                  finishBlock:(nullable void (^)(void))finishBlock;

- (void)postVideoThreadWithTitle:(nonnull NSString *)title
               withTitleRichSpan:(nullable NSString *)titleRichSpan
              withMentionUsers:(nullable NSString *)mentionUsers
             withMentionConcerns:(nullable NSString *)mentionConcerns
                       videoPath:(nonnull NSString *)videoPath
                   videoDuration:(NSInteger)videoDuration
                          height:(CGFloat)height
                           width:(CGFloat)width
                       videoName:(nonnull NSString *)videoName
                 videoSourceType:(TTPostVideoSource)videoSourceType
                      coverImage:(nonnull UIImage *)coverImage
             coverImageTimestamp:(NSTimeInterval)coverImageTimestamp
                videoCoverSource:(TTVideoCoverSourceType)videoCoverSource
                         musicID:(NSString *)musicID
                       concernID:(nonnull NSString *)concernID
                      categoryID:(nullable NSString *)categoryID
                           refer:(NSUInteger)refer
                postUGCEnterFrom:(TTPostUGCEnterFrom)postUGCEnterFrom
                      extraTrack:(nullable NSDictionary *)extraTrack
                     finishBlock:(nullable void(^)(void))finishBlock;

- (void)repostWithRepostThreadModel:(nullable TTRepostThreadModel *)repostThreadModel
                      withConcernID:(nullable NSString *)concernID
                     withCategoryID:(nullable NSString *)categoryID
                              refer:(NSUInteger)refer
                         extraTrack:(nullable NSDictionary *)extraTrack
                        finishBlock:(nullable void(^)(void))finishBlock;

- (void)postShortVideo:(nullable TTRecordedVideo *)video
                  from:(TTPostUGCEnterFrom)postUGCEnterFrom
                 refer:(NSInteger)refer
             concernID:(nullable NSString *)concernID
            categoryID:(nullable NSString *)categoryID
  requestRedPacketType:(TTRequestRedPacketType)requestRedPacketType
      challengeGroupID:(nullable NSString *)challengeGroupID
            extraTrack:(nullable NSDictionary *)extraTrack;

//从磁盘获取tasks，用于启动时加载草稿
- (nullable NSArray <TTForumPostThreadTask *> *)fetchTasksFromDiskForConcernID:(nonnull NSString *)concernID;

- (void)resentVideoForFakeThreadID:(int64_t)fakeTID concernID:(nonnull NSString *)cid;
- (void)resentThreadForFakeThreadID:(int64_t)fakeTID concernID:(nonnull NSString *)cid;
- (void)removeTaskForFakeThreadID:(int64_t)fakeTID concernID:(nonnull NSString *)cid;

+ (void)clearCache;

@end

@interface TTForumPostThreadCenter (ProtocolIMP)<TTUGCPostCenterProtocol>

@end
