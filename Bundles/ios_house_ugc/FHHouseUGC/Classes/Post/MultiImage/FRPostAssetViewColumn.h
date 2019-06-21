//
//  FRPostAssetViewColumn.h
//  Article
//
//  Created by SongChai on 09/06/2017.
//
//

#import <TTThemed/SSViewBase.h>
#import <TTUGCFoundation/TTUGCImageCompressManager.h>

@class TTAssetModel;
@protocol FRPostAssetViewColumnDelegate;

@interface FRPostAssetViewColumn : SSViewBase

@property (nonatomic) NSUInteger column;

@property (nonatomic, assign) BOOL panEnable;
@property (nonatomic, assign) BOOL dragEnable;// default YES
@property (nonatomic, assign) BOOL showPickerLoadingView;// 后续针对icloud加载样式灵活处理，暂时添加屏蔽入口. default YES

@property (nonatomic, weak) id<FRPostAssetViewColumnDelegate> delegate;

@property (nonatomic, strong)TTUGCImageCompressTask *task;

@property (nonatomic,strong,readonly)UIImageView *assetImageView;

- (id)initWithFrame:(CGRect)frame;

- (void)loadWithAsset:(TTAssetModel *) asset;
- (void)loadWithImage:(UIImage*)image;

- (void)reset;
- (void)setDragTargetFrame:(CGRect)targetFrame;
@end


@protocol FRPostAssetViewColumnDelegate <NSObject>
- (void)didTapAssetViewColumn:(FRPostAssetViewColumn *)sender;
- (void)didDeleteAssetViewColumn:(FRPostAssetViewColumn *)sender;
- (void)onDragingAssetViewColumn:(FRPostAssetViewColumn *)sender atPoint:(CGPoint)point;

@optional
- (void)assetViewColumnDidBeginDragging:(FRPostAssetViewColumn *)sender;
- (void)assetViewColumnDidFinishDragging:(FRPostAssetViewColumn *)sender;
@end
