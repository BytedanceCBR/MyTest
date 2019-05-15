//
//  TTVVideoDetailToolBarViewController.h
//  Article
//
//  Created by pei yun on 2017/5/10.
//
//

#import <TTUIWidget/SSViewControllerBase.h>
#import "TTVVideoInformationSyncProtocol.h"
#import "TTVVideoDetailVCDefine.h"
#import "TTVDetailContext.h"

extern NSString * const TTVideoDetailViewControllerDeleteVideoArticle;

@class TTDetailModel;
@class ArticleInfoManager;
@class TTVContainerScrollView;
@interface TTVVideoDetailToolBarViewController : SSViewControllerBase <TTVVideoInformationSyncProtocol, TTVVideoDetailToolbarActionProtocol>

@property (nonatomic, strong) id<TTVArticleProtocol> videoInfo;
@property (nonatomic, strong) TTVWhiteBoard *whiteboard;
@property (nonatomic, assign) BOOL reloadVideoInfoFinished;
@property (nonatomic, strong) TTDetailModel *detailModel;
@property (nonatomic, strong) ArticleInfoManager *infoManager;

@property (nonatomic, weak) id<TTVVideoDetailHomeToToolbarVCActionProtocol> homeActionDelegate;
@property (nonatomic, strong) TTVContainerScrollView *ttvContainerScrollView;

@property (nonatomic, assign) TTVVideoDetailViewShowStatus           showStatus;
@property (nonatomic, assign) BOOL enableScrollToChangeShowStatus;
@property (nonatomic, strong) TTVDetailStateStore *detailStateStore;
@property (nonatomic, assign) BOOL banEmojiInput;
@property (nonatomic, copy) void (^diggActionFired)(BOOL digg);
@property (nonatomic, copy) void (^buryActionFired)(BOOL bury);
@property (nonatomic, copy) void (^commodityActionFired)();
@property (nonatomic, copy) BOOL (^WriteButtonActionFired)();

@property (nonatomic, strong) NSString *writeButtonPlayHoldText;

- (void)_switchShowStatusAnimated:(BOOL)animated isButtonClicked:(BOOL)clicked;
- (void)adTopShareActionFired;
@end
