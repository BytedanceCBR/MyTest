//
//  TTMomentProfileBaseView.h
//  Article
//
//  Created by Chen Hong on 16/8/18.
//
//

#import "SSViewBase.h"
#import "TTMomentProfileShareHelper.h"

#define kDidDiggMomentNotification @"kDidDiggMomentNotification"

@protocol TTMomentProfileProtocol;

@interface TTMomentProfileBaseView : SSViewBase
@property(nonatomic, strong) TTMomentProfileShareHelper *shareHelper;
@property(nonatomic,weak)id<TTMomentProfileProtocol> momentProfileDelegate;
@property (nonatomic, assign) BOOL fromColdStart;
@property (nonatomic, copy) void (^followBlock)(BOOL isFollow);

- (void)shareProfile:(NSDictionary *)data;

- (void)deleteMoment:(NSString *)momentID;

- (void)deleteMomentComment:(NSString *)commentID;

- (void)report:(NSDictionary *)params;

- (void)follow:(NSDictionary *)info;

- (void)unfollow:(NSDictionary *)info;

//- (void)follow:(NSString *)userID;
//
//- (void)unfollow:(NSString *)userID;

- (void)block:(NSString *)userID isBlock:(BOOL)isBlock;

- (void)updateDigg:(NSString *)momentID;

- (void)cancelDigg:(NSString *)momentID;

- (void)updateCommentDigg:(NSString *)commentID;

- (void)updateShortVideoDigg:(NSString *)shortVideoID;

- (void)cancelShortVideoDigg:(NSString *)shortVideoID;

- (void)showCommentViewWithMoment:(NSDictionary *)momentDict commentIndex:(int)commentIndex;

- (void)showGallery:(NSDictionary *)result;

- (NSDictionary *)parseUserProfileData:(NSDictionary *)dict;

@end

@protocol TTMomentProfileProtocol <NSObject>
@optional
- (void)didPublishComment:(NSDictionary *)commentModel momentID:(NSString *)momentID;
- (void)didDigUpdate:(NSString *)momentID;
- (void)didCancelDidUpdate:(NSString *)momentID;
- (void)didDeleteUpdate:(NSString *)momentID;
- (void)didDeleteComment:(NSString *)commentID;
- (void)didDeleteCommentInThread:(NSString *)threadID;
- (void)didForwardUpdate:(NSDictionary *)momentDict;
- (void)didForwardUserInfo:(NSDictionary *)userInfoDict;
- (void)didWeitoutiaoForwardUpdate:(NSDictionary *)dataDict;
- (void)deleteDetailUGCMovie:(NSDictionary *)dict;
- (void)didDeleteThread:(NSString *)threadID;
@end
