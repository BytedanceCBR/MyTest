//
//  TTAdAnimationCell.m
//  Article
//
//  Created by carl on 2017/5/19.
//
//

#import "TTAdAnimationCell.h"

#import "Article+TTADComputedProperties.h"
#import "ExploreArticleTitleLargePicCellView.h"
#import "ExploreArticleTitleRightPicCellView.h"
#import "ExploreOrderedData+TTAd.h"
#import "TTAdCanvasComponent.h"
#import "TTAdCanvasDefine.h"
#import "TTImageInfosModel.h"
#import "TTLayOutGroupPicCell.h"
#import "TTLayOutLargePicCell.h"
#import "TTLayOutRightPicCell.h"
#import "TTUIResponderHelper.h"
#import <TTImage/TTImageView.h>
#import <UIKit/UIKit.h>

static CGRect getFrameOnNavigationChildView(UIView* subView) {
    UIViewController *containterVC = [TTUIResponderHelper topViewControllerFor:subView];
    if (containterVC == nil) {
        return CGRectZero;
    }
    CGRect frame = [subView.superview convertRect:subView.frame toView:containterVC.view];
    return frame;
}

@implementation TTLayOutRightPicCell (TTAdAnimationCell)

- (NSDictionary *)animationContextInfo:(ExploreOrderedData *)orderData {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    Article *article = (Article*)orderData.article;
    NSDictionary *middleImageInfo = article.middleImageDict;
    TTImageInfosModel *imageModel = [[TTImageInfosModel alloc] initWithDictionary:middleImageInfo];
    if (imageModel == nil && [article respondsToSelector:@selector(adModel)]) {
        imageModel = article.adModel.imageModel;
    }
    
    [dict setValue:imageModel forKey:kTTCanvasSourceImageModel];
    TTLayOutRightPicCellView* cellView = (TTLayOutRightPicCellView *)self.cellView;
    if (cellView) {
        TTImageView* picView1 = cellView.picView.picView1;
        CGRect frame = getFrameOnNavigationChildView(picView1);
        [dict setValue:NSStringFromCGRect(frame) forKey:kTTCanvasSourceImageFrame];
    }
    return dict;
}

@end

@implementation ExploreArticleTitleRightPicCell (TTAdAnimationCell)

- (NSDictionary *)animationContextInfo:(ExploreOrderedData *)orderData {
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    Article* article = (Article*)orderData.article;
    TTImageInfosModel *imageModel = [[TTImageInfosModel alloc] initWithDictionary:[article middleImageDict]];
    if (!imageModel && [article respondsToSelector:@selector(adModel)]) {
        imageModel = orderData.adModel.imageModel;
    }
    [dict setValue:imageModel forKey:kTTCanvasSourceImageModel];
    
    ExploreArticleTitleRightPicCellView *cellView = (ExploreArticleTitleRightPicCellView *)self.cellView;
    if (cellView) {
        TTImageView *picView1 = cellView.picView.picView1;
        CGRect frame = getFrameOnNavigationChildView(picView1);
        [dict setValue:NSStringFromCGRect(frame) forKey:kTTCanvasSourceImageFrame];
    }
    return dict;
}

@end

@implementation TTLayOutLargePicCell (TTAdAnimationCell)

- (NSDictionary *)animationContextInfo:(ExploreOrderedData *)orderData {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    Article *article = (Article *)orderData.article;
    TTImageInfosModel *imageModel = [[TTImageInfosModel alloc] initWithDictionary:[article largeImageDict]];
    if (imageModel == nil && [article respondsToSelector:@selector(adModel)]) {
        imageModel = article.adModel.imageModel;
    }
    [dict setValue:imageModel forKey:kTTCanvasSourceImageModel];
    
    TTAdCanvasComponent *component = nil;
    if (article.hasVideo && article.videoDetailInfo.count > 0) {
        component = [[TTAdCanvasComponentVideo alloc] initWithDictionary:article.videoDetailInfo error:nil];
        [dict setValue:[component exportComponent] forKey:kTTCanvasFeedData];
    } else {
        component = [[TTAdCanvasComponentPicture alloc] initWithImageModel:imageModel];
        [dict setValue:[component exportComponent] forKey:kTTCanvasFeedData];
    }
    
    TTLayOutLargePicCellView *cellView = (TTLayOutLargePicCellView*)self.cellView;
    if (cellView) {
        TTImageView *picView1 = cellView.picView.picView1;
        CGRect frame = getFrameOnNavigationChildView(picView1);
        [dict setValue:NSStringFromCGRect(frame) forKey:kTTCanvasSourceImageFrame];
    }
    return dict;
}

@end

@implementation TTLayOutNewLargePicCell (TTAdAnimationCell)

- (NSDictionary *)animationContextInfo:(ExploreOrderedData *)orderData {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    Article *article = (Article*)orderData.article;
    TTImageInfosModel *imageModel = [[TTImageInfosModel alloc] initWithDictionary:[article largeImageDict]];
    if (imageModel == nil && [article respondsToSelector:@selector(adModel)]) {
        imageModel = article.adModel.imageModel;
    }
    [dict setValue:imageModel forKey:kTTCanvasSourceImageModel];
    TTAdCanvasComponent *component = nil;
    if (article.hasVideo && article.videoDetailInfo.count > 0) {
        component = [[TTAdCanvasComponentVideo alloc] initWithDictionary:article.videoDetailInfo error:nil];
        [dict setValue:[component exportComponent] forKey:kTTCanvasFeedData];
    } else {
        component = [[TTAdCanvasComponentPicture alloc] initWithImageModel:imageModel];
        [dict setValue:[component exportComponent] forKey:kTTCanvasFeedData];
    }
    
    TTLayOutLargePicCellView *cellView = (TTLayOutLargePicCellView *)self.cellView;
    if (cellView) {
        TTImageView *picView1 = cellView.picView.picView1;
        CGRect frame = getFrameOnNavigationChildView(picView1);
        [dict setValue:NSStringFromCGRect(frame) forKey:kTTCanvasSourceImageFrame];
    }
    return dict;
}

@end


@implementation ExploreArticleTitleLargePicCell (TTAdAnimationCell)
- (NSDictionary *)animationContextInfo:(ExploreOrderedData *)orderData {
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    Article *article = (Article*)orderData.article;
    TTImageInfosModel *imageModel = [[TTImageInfosModel alloc] initWithDictionary:[article largeImageDict]];
    if (!imageModel && [article respondsToSelector:@selector(adModel)]) {
        imageModel = orderData.adModel.imageModel;
    }
    [dict setValue:imageModel forKey:kTTCanvasSourceImageModel];
    TTAdCanvasComponent *component = nil;
    if (article.hasVideo && article.videoDetailInfo.count > 0) {
        component = [[TTAdCanvasComponentVideo alloc] initWithDictionary:article.videoDetailInfo error:nil];
        [dict setValue:[component exportComponent] forKey:kTTCanvasFeedData];
    } else {
        component = [[TTAdCanvasComponentPicture alloc] initWithImageModel:imageModel];
        [dict setValue:[component exportComponent] forKey:kTTCanvasFeedData];
    }
    
    ExploreArticleTitleLargePicCellView *cellView = (ExploreArticleTitleLargePicCellView *)self.cellView;
    if (cellView) {
        TTImageView* picView1 = cellView.picView.picView1;
        CGRect frame = getFrameOnNavigationChildView(picView1);
        [dict setValue:NSStringFromCGRect(frame) forKey:kTTCanvasSourceImageFrame];
    }
    return dict;
}

@end


@implementation TTLayoutPanoramaViewCell (TTAdAnimationCell)
- (NSDictionary *)animationContextInfo:(ExploreOrderedData *)orderData {
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    Article* article = (Article*)orderData.article;
    TTImageInfosModel *imageModel = [[TTImageInfosModel alloc] initWithDictionary:[article largeImageDict]];
    if (!imageModel && [article respondsToSelector:@selector(adModel)]) {
        imageModel = orderData.adModel.imageModel;
    }
    [dict setValue:imageModel forKey:kTTCanvasSourceImageModel];
    TTLayoutPanoramaCellView *cellView = (TTLayoutPanoramaCellView *)self.cellView;
    if (cellView) {
        UIView* picView1 = cellView.panoramaView;
        CGRect frame = getFrameOnNavigationChildView(picView1);
        [dict setValue:NSStringFromCGRect(frame) forKey:kTTCanvasSourceImageFrame];
    }
    return dict;
}

@end

@implementation TTLayoutPanorama3DViewCell (TTAdAnimationCell)
- (NSDictionary *)animationContextInfo:(ExploreOrderedData *)orderData {
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    Article* article = (Article*)orderData.article;
    TTImageInfosModel *imageModel = [[TTImageInfosModel alloc] initWithDictionary:[article largeImageDict]];
    if (!imageModel && [article respondsToSelector:@selector(adModel)]) {
        imageModel = article.adModel.imageModel;
    }
    [dict setValue:imageModel forKey:kTTCanvasSourceImageModel];
    TTLayoutPanoramaCellView *cellView = (TTLayoutPanoramaCellView *)self.cellView;
    if (cellView) {
        UIView* picView1 = cellView.panoramaView;
        CGRect frame = getFrameOnNavigationChildView(picView1);
        [dict setValue:NSStringFromCGRect(frame) forKey:kTTCanvasSourceImageFrame];
    }
    return dict;
}

@end

