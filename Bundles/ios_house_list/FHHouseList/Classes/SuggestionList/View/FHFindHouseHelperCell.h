//
//  FHFindHouseHelperCell.h
//  AKCommentPlugin
//
//  Created by wangxinyu on 2020/6/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHFindHouseHelperCell : UITableViewCell

@property (nonatomic, copy) void(^cellTapAction)(void);

@end

NS_ASSUME_NONNULL_END
