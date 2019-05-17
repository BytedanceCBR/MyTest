//
//  TTPhotoNewCommentViewController.h
//  Article
//
//  Created by zhaoqin on 09/01/2017.
//
//

#import "SSViewControllerBase.h"
#import "TTDetailModel.h"
#import "ArticleInfoManager.h"
#import "TTModalWrapController.h"


@class TTPhotoNewCommentViewController;
@protocol TTPhotoNewCommentViewControllerDelegate <NSObject>

@optional
- (void)ttPhotoNewCommentViewControllerDisappear:(TTPhotoNewCommentViewController *)photoCommentVC;
- (void)ttPhotoNewCommentViewControllerAppear:(TTPhotoNewCommentViewController *)photoCommentVC;
@end

@interface TTPhotoNewCommentViewController : SSViewControllerBase<TTModalWrapControllerProtocol>

@property (nonatomic,weak) id<TTPhotoNewCommentViewControllerDelegate> delegate;
@property (nonatomic, strong) TTArticleReadQualityModel *readQuality;
@property (nonatomic, assign) BOOL automaticallyTriggerCommentAction;
@property (nonatomic ,assign)  CGRect originRect;
@property (nonatomic, strong) ArticleInfoManager *infoManager;
@property (nonatomic, assign) BOOL hasNestedInModalContainer;

- (instancetype) initViewModel:(TTDetailModel *)model;

//手势下滑退出
//- (void)addSlideDownOutGesture:(UIViewController *)aimVC orientation:(UIInterfaceOrientation)orientation;
/** 添加一条评论并返回顶部 */
- (void)insertCommentWithDict:(NSDictionary *)data;

@end
