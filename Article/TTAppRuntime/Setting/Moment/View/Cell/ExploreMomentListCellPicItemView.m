//
//  ExploreMomentListCellPicItemView.m
//  Article
//
//  Created by Zhang Leonardo on 15-1-18.
//
//

#import "ExploreMomentListCellPicItemView.h"
#import "ExploreMomentImageAlbum.h"
#import "TTPhotoScrollViewController.h"
#import "UIViewController+NavigationBarStyle.h"
#import "TTDeviceUIUtils.h"
#import "ArticleMomentGroupModel.h"
#import <TTInteractExitHelper.h>
#import "TTTabBarProvider.h"

#define kTopPadding [TTDeviceUIUtils tt_paddingForMoment:5]
#define kBottomPadding 0

@interface ExploreMomentListCellPicItemView()<ExploreMomentImageAlbumDelegate>
@property(nonatomic, retain)UILabel * titleLabel;
@property (nonatomic, strong)ExploreMomentImageAlbum *imageAlbum;
@end

@implementation ExploreMomentListCellPicItemView

- (void)dealloc
{
    self.imageAlbum.delegate = nil;
    self.imageAlbum = nil;
}

- (id)initWithWidth:(CGFloat)cellWidth userInfo:(NSDictionary *)uInfo
{
    self = [super initWithWidth:cellWidth userInfo:uInfo];
    if (self) {
        self.imageAlbum = [[ExploreMomentImageAlbum alloc] initWithFrame:CGRectZero];
        _imageAlbum.albumStyle = ExploreMomentImageAlbumUIStyleMoment;
        _imageAlbum.delegate = self;
        self.imageAlbum.margin = 2;
        [self addSubview:self.imageAlbum];
    }
    return self;
}

- (void)refreshForMomentModel:(ArticleMomentModel *)model
{
    [super refreshForMomentModel:model];
    self.imageAlbum.frame = CGRectMake([TTDeviceUIUtils tt_paddingForMoment:60], kTopPadding, self.width - [TTDeviceUIUtils tt_paddingForMoment:75], self.height - kTopPadding - kBottomPadding);
    self.imageAlbum.images = model.thumbImageList;
    
}

- (CGFloat)heightForMomentModel:(ArticleMomentModel *)model cellWidth:(CGFloat)cellWidth
{
    return [ExploreMomentListCellPicItemView heightForMomentModel:model cellWidth:cellWidth userInfo:self.userInfo];
}

+ (CGFloat)heightForMomentModel:(ArticleMomentModel *)model cellWidth:(CGFloat)cellWidth userInfo:(NSDictionary *)uInfo
{
    if (![self needShowForModel:model userInfo:uInfo]) {
        return 0;
    }
    if (model.thumbImageList.count == 0) {
        return 0;
    }
    return [ExploreMomentImageAlbum heightForImages:model.thumbImageList constrainedToWidth:cellWidth - [TTDeviceUIUtils tt_paddingForMoment:75] margin:2] + kTopPadding + kBottomPadding;
}

+ (BOOL)needShowForModel:(ArticleMomentModel *)model userInfo:(NSDictionary *)uInfo
{
    return YES;
}

- (void)openPhotoForIndex:(NSUInteger)index
{
    if ([self.momentModel.largeImageList count] == 0) {
        return;
    }

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:self.momentModel.ID forKey:@"id"];
    
    if (self.sourceType == ArticleMomentSourceTypeForum) {
        [TTTrackerWrapper category:@"umeng" event:@"image" label:@"enter_topic" dict:dict];
    } else if (self.sourceType == ArticleMomentSourceTypeMoment
               || self.sourceType == ArticleMomentSourceTypeProfile) {
        [TTTrackerWrapper category:@"umeng" event:@"image" label:@"enter_update" dict:dict];
    }

    TTPhotoScrollViewController * showImageViewController = [[TTPhotoScrollViewController alloc] init];
    showImageViewController.targetView = self;
    showImageViewController.finishBackView = [TTInteractExitHelper getSuitableFinishBackViewWithCurrentContext];
    NSArray *infoModels = self.momentModel.largeImageList;
    showImageViewController.imageInfosModels = infoModels;
    showImageViewController.placeholders = self.imageAlbum.displayImages;
    showImageViewController.placeholderSourceViewFrames = self.imageAlbum.displayImageViewFrames;
    [showImageViewController setStartWithIndex:index];
    [showImageViewController presentPhotoScrollView];
}

#pragma mark -- ExploreMomentImageAlbumDelegate

- (void)imageAlbum:(ExploreMomentImageAlbum *)imageAlbum didClickImageAtIndex:(NSInteger)index
{
    if (self.sourceType == ArticleMomentSourceTypeMoment) {
        if ([TTTabBarProvider isWeitoutiaoOnTabBar]) {
            NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
            [extra setValue:self.momentModel.ID forKey:@"item_id"];
            [extra setValue:self.momentModel.group.ID forKey:@"value"];
            [TTTrackerWrapper event:@"micronews_tab" label:@"picture" value:nil extValue:nil extValue2:nil dict:[extra copy]];
        }
    }
    [self openPhotoForIndex:index];
}

@end
