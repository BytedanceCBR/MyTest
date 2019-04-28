//
//  TTPhotoCommentViewController.h
//  Article
//
//  Created by yuxin on 4/20/16.
//
//

#import "SSViewControllerBase.h"
#import "TTDetailModel.h"
#import "ArticleInfoManager.h"
#import "TTNavigationController.h"


@protocol TTCommentViewControllerDelegate;

@interface TTPhotoCommentViewController : SSViewControllerBase

@property (nonatomic, strong) TTArticleReadQualityModel *readQuality;
@property (nonatomic, assign) BOOL automaticallyTriggerCommentAction;
@property (nonatomic, assign) CGRect originRect;
@property (nonatomic, strong) ArticleInfoManager *infoManager;
@property (nonatomic, nullable, weak) id <TTCommentViewControllerDelegate> delegate;
@property (nonatomic, assign) BOOL banEmojiInput;

- (instancetype)initViewModel:(TTDetailModel *)model delegate:(nullable id<TTCommentViewControllerDelegate>)delegate NS_DESIGNATED_INITIALIZER;

//手势下滑退出
- (void)addSlideDownOutGesture:(UIViewController *)aimVC orientation:(UIInterfaceOrientation)orientation;
/** 添加一条评论并返回顶部 */
- (void)insertCommentWithDict:(NSDictionary *)data;

@end
