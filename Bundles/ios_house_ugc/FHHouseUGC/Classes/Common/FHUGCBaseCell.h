//
//  FHUGCBaseCell.h
//  FHHouseUGC
//
//  Created by 张元科 on 2019/6/3.
//

#import <UIKit/UIKit.h>
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "Masonry.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "FHFeedContentModel.h"
#import "FHFeedUGCContentModel.h"
#import "FHFeedUGCCellModel.h"
#import "FHUGCBaseViewModel.h"
#import "TTBaseMacro.h"

NS_ASSUME_NONNULL_BEGIN

@class FHUGCBaseCell;

@protocol FHUGCBaseCellDelegate <NSObject>

@optional
- (void)deleteCell:(FHFeedUGCCellModel *)cellModel;

- (void)commentClicked:(FHFeedUGCCellModel *)cellModel cell:(FHUGCBaseCell *)cell;

- (void)goToCommunityDetail:(FHFeedUGCCellModel *)cellModel;

- (void)lookAllLinkClicked:(FHFeedUGCCellModel *)cellModel cell:(FHUGCBaseCell *)cell;

- (void)closeFeedGuide:(FHFeedUGCCellModel *)cellModel;

- (void)gotoLinkUrl:(FHFeedUGCCellModel *)cellModel url:(NSURL *)url;

- (void)goToVoteDetail:(FHFeedUGCCellModel *)cellModel value:(NSInteger)value;

- (void)clickRealtorHeaderLicense:(FHFeedUGCCellModel *)cellModel cell:(FHUGCBaseCell *)cell;

- (void)clickRealtorIm:(FHFeedUGCCellModel *)cellModel cell:(FHUGCBaseCell *)cell;

- (void)clickRealtorPhone:(FHFeedUGCCellModel *)cellModel cell:(FHUGCBaseCell *)cell;

- (void)clickRealtorHeader:(FHFeedUGCCellModel *)cellModel cell:(FHUGCBaseCell *)cell;

- (void)didVideoClicked:(FHFeedUGCCellModel *)cellModel cell:(FHUGCBaseCell *)cell;

@end

@interface FHUGCBaseCell : UITableViewCell
// Cell装饰
@property(nonatomic ,strong) UIImageView *decorationImageView;

// 当前cell的模型数据
@property (nonatomic, weak , nullable) id currentData;

// 当前方法不需重写
+ (Class)cellViewClass;

// 子类需要重写的方法，根据数据源刷新当前Cell，以及布局
- (void)refreshWithData:(id)data;


+ (CGFloat)heightForData:(id)data;

// Cell点击事件，可以不用实现
@property (nonatomic, copy)     dispatch_block_t       didClickCellBlk;

// 详情页baseViewModel，可以从中拿到需要的数据(高效但是不美观)
@property (nonatomic, weak)     FHUGCBaseViewModel       *baseViewModel;

@property(nonatomic , weak) id<FHUGCBaseCellDelegate> delegate;

// 当前cell所需基础埋点数据，更新refreshWithData的时候赋值
@property (nonatomic, copy)     NSDictionary       *tracerDic;

// 是否是详情页，默认是NO
@property (nonatomic, assign)   BOOL       isFromDetail;

@end

// FHUGCBaseCollectionCell
@interface FHUGCBaseCollectionCell : UICollectionViewCell

// 当前cell的模型数据
@property (nonatomic, weak , nullable) id currentData;

// 当前方法不需重写
+ (Class)cellViewClass;

// 子类需要重写的方法，根据数据源刷新当前Cell，以及布局
- (void)refreshWithData:(id)data;

// Cell点击事件，可以不用实现
@property (nonatomic, copy)     dispatch_block_t       didClickCellBlk;

@end

NS_ASSUME_NONNULL_END
