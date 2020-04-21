//
//  FHLynxCell.h
//  AKCommentPlugin
//
//  Created by 谢飞 on 2020/4/21.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class LynxView;
@class FHLynxViewBaseParams;

@interface FHLynxCell : UITableViewCell

@property(nonatomic, strong) LynxView* lynxView;

@property(nonatomic) CGSize size;

@property (nonatomic, strong) FHLynxViewBaseParams *params;

// 当前cell的模型数据
@property (nonatomic, weak , nullable) id currentData;

// 当前方法不需重写
+ (Class)cellViewClass;

// 子类需要重写的方法，根据数据源刷新当前Cell，以及布局
- (void)refreshWithData:(id)data;

// Cell点击事件，可以不用实现
@property (nonatomic, copy)     dispatch_block_t       didClickCellBlk;


// 是否上报house_show
- (NSDictionary *)elementHouseShowUpload;

// 即将显示cell
- (void)fh_willDisplayCell;

// cell消失
- (void)fh_didEndDisplayingCell;

@end

NS_ASSUME_NONNULL_END
