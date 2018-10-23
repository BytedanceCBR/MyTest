//
//  TTVFeedListCell+TTAdAnimationCell.m
//  Article
//
//  Created by pei yun on 2017/10/24.
//

#import "TTVFeedListCell+TTAdAnimationCell.h"
#import "TTImageInfosModel+Extention.h"
#import "TTVFeedListTopImageContainerView.h"
#import "TTAdCanvasDefine.h"
#import <TTVideoService/TTVFeedItem+Extension.h>
#import <TTVideoService/PBModelHeader.h>
#import "TTAdCanvasComponent.h"
#import "TTVFeedListPicAdItem.h"

static CGRect ttv_getFrameOnNavigationChildView(UIView* subView) {
    UIViewController *containerVC = [TTUIResponderHelper topViewControllerFor:subView];
    if (containerVC == nil) {
        return CGRectZero;
    }
    CGRect frame = [subView.superview convertRect:subView.frame toView:containerVC.view];
    return frame;
}

@implementation TTVFeedListCell (TTAdAnimationCell)

- (NSDictionary *)animationContextInfo:(ExploreOrderedData *)orderData {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    TTVVideoArticle *article = self.item.originData.article;
    TTImageInfosModel *imageModel = [[TTImageInfosModel alloc] initWithImageUrlList:article.largeImageList];
    [dict setValue:imageModel forKey:kTTCanvasSourceImageModel];
    
    if (article.hasVideo && article.videoDetailInfo != nil) {
        TTAdCanvasComponentVideo *component = [[TTAdCanvasComponentVideo alloc] initWithImageModel:imageModel videoID:article.videoId];
        [dict setValue:[component exportComponent] forKey:kTTCanvasFeedData];
    } else {
        TTAdCanvasComponentPicture *component = [[TTAdCanvasComponentPicture alloc] initWithImageModel:imageModel];
        [dict setValue:[component exportComponent] forKey:kTTCanvasFeedData];
    }
    
    UIView *logo = self.topMovieContainerView.logo;
    if (logo == nil && [self isKindOfClass:[TTVFeedListPicAdCell class]]) {
        TTVFeedListPicAdCell *picAdCell = (TTVFeedListPicAdCell *)self;
        logo = picAdCell.topContainerView;
    }
    CGRect frame = ttv_getFrameOnNavigationChildView(logo);
    [dict setValue:NSStringFromCGRect(frame) forKey:kTTCanvasSourceImageFrame];
    
    return dict;
}

@end
