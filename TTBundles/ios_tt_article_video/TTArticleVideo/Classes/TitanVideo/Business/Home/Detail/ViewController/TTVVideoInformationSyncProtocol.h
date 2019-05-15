//
//  TTVVideoInformationSyncProtocol.h
//  Article
//
//  Created by pei yun on 2017/5/8.
//
//

#ifndef TTVVideoInformationSyncProtocol_h
#define TTVVideoInformationSyncProtocol_h

#import "TTVArticleProtocol.h"
#import "TTVWhiteBoard.h"
#import "TTVVideoDetailVCDefine.h"
#import <TTVideoService/VideoInformation.pbobjc.h>

@protocol TTVVideoInformationSyncProtocol <NSObject>

@optional
- (void)setVideoInfo:(id<TTVArticleProtocol> )videoInfo;
- (void)setWhiteboard:(TTVWhiteBoard *)whiteboard;
- (void)setReloadVideoInfoFinished:(BOOL)reloadVideoInfoFinished;

@end

@protocol TTVVideoDetailToolbarActionProtocol <NSObject>

@optional
- (void)_writeCommentActionFired;
- (void)_showCommentActionFired;
- (void)_collectActionFired;
- (void)_shareActionFired:(BOOL )isFullScreen;
- (void)_videoOverShareActionFired;
- (void)_videoOverMoreActionFired;
- (void)_videoPlayMoreActionFired:(BOOL )isFullScrren;
- (void)_videoPlayShareActionFired;
- (void)_videoOverDirectShareItemActionWithActivityType:(NSString *)activityType;
- (void)_videoPlayDirectShareItemActionWithActivityType:(NSString *)activityType;
- (void)_detailCentrelShareActionFired;
- (void)_detailCentrelDirectShareItemAction:(NSString *)activityType;


@end

@protocol TTVVideoDetailHomeToToolbarVCActionProtocol <NSObject>

@optional
- (void)_scrollToCommentListHeadAnimated:(BOOL)animated;
- (void)vdvi_changeMovieSizeWithStatus:(TTVVideoDetailViewShowStatus)status;
- (void)_topViewBackButtonPressed;

@end

@protocol TTVVideoDetailHomeToHeaderActionProtocol <NSObject>

@optional
- (CGFloat)maxWidth;
- (void)sendADEvent:(NSString *)event label:(NSString *)label value:(NSString *)value extra:(NSDictionary *)extra logExtra:(NSString *)logExtra click:(BOOL)click;
- (void)adjustContainerScrollViewHeight;
- (BOOL)shouldPauseMovieWhenVCDidDisappear;

@end

@protocol TTVVideoDetailHomeToRelatedVideoVCActionProtocol <NSObject>

@optional
- (void)_showVideoAlbumWithItem:(TTVRelatedItem * )relatedItem;
- (void)_showVideoAlbumWithAritcle:(id<TTVArticleProtocol> )article;
- (BOOL)detailVCIsFromList;
- (void)ttv_invalideMovieView;
- (BOOL)originalStatusBarHidden;
- (UIStatusBarStyle)originalStatusBarStyle;

@end

#endif /* TTVVideoInformationSyncProtocol_h */
