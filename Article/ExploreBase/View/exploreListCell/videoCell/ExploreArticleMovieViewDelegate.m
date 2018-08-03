//
//  ExploreArticleMovieViewDelegate.m
//  Article
//
//  Created by Chen Hong on 15/8/31.
//
//

#import "ExploreArticleMovieViewDelegate.h"
#import "TTRoute.h"
#import "Article.h"
#import "NewsDetailConstant.h"
#import "TTStringHelper.h"
#import "TTMovieFullscreenViewController.h"
#import "TTModuleBridge.h"
#import "ExploreOrderedData+TTAd.h"

@implementation ExploreArticleMovieViewDelegate

#pragma mark - ExploreMovieViewDelegate
+ (void)load
{
    [[TTModuleBridge sharedInstance_tt] registerAction:@"NewMovieViewDelegate" withBlock:^id _Nullable(id  _Nullable object, id  _Nullable params) {
        
        ExploreOrderedData *orderedData = (ExploreOrderedData *)[params tt_objectForKey:@"orderedData"];
        SSViewBase *videoCoverPicView = (SSViewBase *)[params tt_objectForKey:@"videoCoverPicView"];
        SSViewBase *viewBase = (SSViewBase *)[params tt_objectForKey:@"viewBase"];
        dispatch_block_t shareButtonClickedBlock = [params tt_objectForKey:@"shareButtonClickedBlock"];
        
        ExploreArticleMovieViewDelegate *movieViewDelegate = [[ExploreArticleMovieViewDelegate alloc] init];
        movieViewDelegate.orderedData = orderedData;
        movieViewDelegate.viewBase = viewBase;
        movieViewDelegate.logo = videoCoverPicView;
        movieViewDelegate.shareButtonClickedBlock = shareButtonClickedBlock;
        return movieViewDelegate;
    }];
}

- (void)showDetailButtonClicked
{
    if (self.orderedData && self.orderedData.managedObjectContext) {
        TTGroupModel *groupModel = self.orderedData.article.groupModel;
        if (!isEmptyString(groupModel.groupID)) {
            NSMutableDictionary *statParams = [NSMutableDictionary dictionary];
            [statParams setValue:self.orderedData.categoryID forKey:kNewsDetailViewConditionCategoryIDKey];
            [statParams setValue:self.orderedData forKey:@"ordered_data"];
            
            NSString *detailURL = [NSString stringWithFormat:@"sslocal://detail?groupid=%@&itemid=%@&aggrtype=%@&gd_label=%@", groupModel.groupID, groupModel.itemID, @(groupModel.aggrType), @"click_video"];
            
            NSString * aID = self.orderedData.ad_id;
            
            if (!isEmptyString(aID)) {
                detailURL = [detailURL stringByAppendingFormat:@"&ad_id=%@", aID];
            }
            //播放完成点击查看详情需要给embeded_id发click事件
            wrapperTrackEvent(@"embeded_ad", @"click");
            [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:detailURL] userInfo:TTRouteUserInfoWithDict(statParams)];
        }
    }
}

- (CGRect)movieViewFrameAfterExitFullscreen
{
    return self.logo.bounds;
}

- (BOOL)shouldResumePlayWhenActive
{
    if (_viewBase) {
        UINavigationController *navigation = [_viewBase navigationController];
        if ((navigation.viewControllers.count == 1 && !navigation.presentedViewController )|| ([navigation.presentedViewController isKindOfClass:[TTMovieFullscreenViewController class]] && !navigation.presentedViewController.presentedViewController)) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)shouldDisableUserInteraction
{
    if ([self.orderedData couldAutoPlay]) {
        return YES;
    }
    return NO;
}

- (BOOL)shouldStopMovieWhenInBackground
{
    if ([self.orderedData couldAutoPlay]) {
        return YES;
    }
    return NO;
}

- (void)FullScreenshareButtonClicked{
    
    if (_playerShareButtonClickedBlock) {
        _playerShareButtonClickedBlock();
    }
}

- (void)shareButtonClicked
{
    if (_shareButtonClickedBlock) {
        _shareButtonClickedBlock();
    }
}

- (void)moreButtonClicked
{
    if (_moreButtonClickedBlock) {
        _moreButtonClickedBlock();
    }
}

- (void)shareActionClickedWithActivityType:(NSString *)activityType
{
    if(self.shareActionClickedBlock){
        self.shareActionClickedBlock(activityType);
    }
}

- (void)movieViewWillMoveToSuperView:(UIView *)newView{
    if (self.movieViewWillAppear) {
        self.movieViewWillAppear(newView);
    }
}

- (void)replayButtonClicked{
    if (self.replayButtonClickedBlock) {
        self.replayButtonClickedBlock();
    }
}

@end
