//
//  FHUGCLynxCommonCell.h
//  AKCommentPlugin
//
//  Created by 谢飞 on 2020/5/6.
//

#import "FHUGCBaseCell.h"

NS_ASSUME_NONNULL_BEGIN
@class LynxView;

@interface FHUGCLynxCommonCell : FHUGCBaseCell

@property(nonatomic, weak) UITableView* tableView;

@property(nonatomic, strong) LynxView* lynxView;

@property(nonatomic) CGSize size;

@property(nonatomic) CGSize cacheSize;

@end

NS_ASSUME_NONNULL_END
