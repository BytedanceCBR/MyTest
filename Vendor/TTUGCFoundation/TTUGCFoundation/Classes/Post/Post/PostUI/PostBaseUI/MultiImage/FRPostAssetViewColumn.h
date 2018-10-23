//
//  FRPostAssetViewColumn.h
//  Article
//
//  Created by SongChai on 09/06/2017.
//
//

#import "SSViewBase.h"
#import "TTForumPostImageCache.h"

@class TTAssetModel;
@protocol FRPostAssetViewColumnDelegate;

@interface FRPostAssetViewColumn : SSViewBase

@property (nonatomic) NSUInteger column;

@property (nonatomic, weak) id<FRPostAssetViewColumnDelegate> delegate;

@property (nonatomic, strong)TTForumPostImageCacheTask *task;

@property (nonatomic,strong,readonly)UIImageView *assetImageView;

- (id)initWithFrame:(CGRect)frame;

- (void) loadWithAsset:(TTAssetModel*) asset;
- (void) loadWithImage:(UIImage*)image;
@end


@protocol FRPostAssetViewColumnDelegate <NSObject>
- (void)didTapAssetViewColumn:(FRPostAssetViewColumn *)sender;
- (void)didDeleteAssetViewColumn:(FRPostAssetViewColumn *)sender;
@end
