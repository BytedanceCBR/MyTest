//
//  FHUGCLynxBannerCell.h
//  AKCommentPlugin
//
//  Created by 谢飞 on 2020/4/24.
//

#import "FHLynxCell.h"
#import "FHUGCBannerCell.h"
#import "FHFeedUGCCellModel.h"

NS_ASSUME_NONNULL_BEGIN
@class LynxView;

@interface FHUGCLynxBannerCell : FHUGCBaseCell

@property(nonatomic, weak) UITableView* tableView;

@property(nonatomic, strong) LynxView* lynxView;

@property(nonatomic) CGSize size;

@property(nonatomic) CGSize cacheSize;

@end

NS_ASSUME_NONNULL_END
