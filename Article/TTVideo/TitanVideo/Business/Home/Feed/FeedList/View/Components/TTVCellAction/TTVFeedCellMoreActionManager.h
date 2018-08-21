//
//  TTVFeedCellMoreActionManager.h
//  Article
//
//  Created by panxiang on 2017/4/10.
//
//

#import <Foundation/Foundation.h>
#import "TTVFeedItem+Extension.h"
#import "ArticleShareManager.h"
#import "TTVMoreAction.h"
#import "ExploreItemActionManager.h"

@interface TTVFeedCellMoreActionModel : NSObject
@property (nonatomic ,strong)NSNumber *adID;
@property (nonatomic ,copy)NSString *avatarUrl;
@property (nonatomic, strong) NSNumber *userRepined;
@property (nonatomic, strong) NSNumber *buryCount;
@property (nonatomic, strong) NSNumber *commentCount;
@property (nonatomic, strong) NSNumber *diggCount;
@property (nonatomic, strong) NSNumber *userDigg;
@property (nonatomic, strong) NSNumber *userBury;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *groupId;
@property (nonatomic, copy) NSString *itemId;
@property (nonatomic, assign) NSInteger groupFlags;
@property (nonatomic, strong) NSNumber *isSubscribe;
@property (nonatomic, strong) NSString *logExtra;
@property (nonatomic, strong) TTShareModel *shareModel;
@property (nonatomic, copy) NSString *videoSubjectID;
@property(nonatomic, strong) NSNumber *aggrType;
@property (nonatomic, assign) NSInteger refer;
@property (nonatomic, copy) NSString *videoSource;
@property (nonatomic, copy) NSArray *commoditys;
@property (nonatomic, strong) NSArray <NSDictionary *> *filterWords;
@property (nonatomic, assign) BOOL hasVideo;
+ (TTVFeedCellMoreActionModel *)modelWithArticle:(TTVFeedItem *)item;
@end

@class TTVPlayVideo;
@interface TTVFeedCellMoreActionManager : NSObject 
@property (nonatomic, copy) NSString *categoryId;
@property (nonatomic ,weak)UIResponder *responder;
@property (nonatomic, strong) TTVFeedItem *cellEntity;
@property (nonatomic, copy) void (^didClickDislikeSubmitButtonBlock)(TTVFeedItem *cellEntity, NSArray *filterWords, CGRect dislikeAnchorFrame, TTDislikeSourceType dislikeSourceType);
@property (nonatomic, copy) UIViewController *(^getPresentingViewControllerOfShare)(UIResponder *responder);
@property (nonatomic, copy) BOOL (^didClickActivityItemAndQueryProcess)(NSString *type);
@property (nonatomic, copy) void (^shareToRepostBlock)(TTActivityType type);
@property (nonatomic, weak) UIView *dislikePopFromView;//显示dislike pop from unInterestedButton
@property (nonatomic, weak) TTVPlayVideo *playVideo;

//- (void)addAction:(TTVMoreAction *)action;
- (void)moreButtonClickedWithModel:(TTVFeedCellMoreActionModel *)model activityAction:(void(^)(NSString *type))activityAction;
- (void)shareButtonClickedWithModel:(TTVFeedCellMoreActionModel *)model activityAction:(void(^)(NSString *type))activityAction;
- (void)shareActionOnMovieTopViewWithModel:(TTVFeedCellMoreActionModel *)model activityAction:(void(^)(NSString *type))activityAction;
- (void)moreActionOnMovieTopViewWithModel:(TTVFeedCellMoreActionModel *)model activityAction:(void(^)(NSString *type))activityAction;
- (void)shareButtonOnMovieClickedWithModel:(TTVFeedCellMoreActionModel *)model activityAction:(void(^)(NSString *type))activityAction;
- (void)directShareOnMovieFinishViewWithModel:(TTVFeedCellMoreActionModel *)model activityType:(NSString *)itemType activityAction:(void (^)(NSString *))activityType;
- (void)directShareOnMovieViewWithModel:(TTVFeedCellMoreActionModel *)model activityType:(NSString *)itemType activityAction:(void (^)(NSString *))activityType;
- (void)directShareOnBottomViewWithModel:(TTVFeedCellMoreActionModel *)model activityType:(NSString *)itemType activityAction:(void (^)(NSString *))activityType;
- (void)dismissWithAnimation:(BOOL)animated;
//- (void)commentButtonClickedWithModel:(TTVFeedCellMoreActionModel *)model;
@end
