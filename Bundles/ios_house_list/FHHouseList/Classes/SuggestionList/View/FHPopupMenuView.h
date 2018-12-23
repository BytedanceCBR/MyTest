//
//  FHPopupMenuView.h
//  FHHouseList
//
//  Created by 张元科 on 2018/12/23.
//

#import <UIKit/UIKit.h>
#import "FHHouseType.h"

/* 回跳到上一级页面，回传参数 */
typedef void(^FHPopupMenuItemClickBlock)(FHHouseType houseType);

NS_ASSUME_NONNULL_BEGIN

@interface FHPopupMenuView : UIControl

// FHPopupMenuItem
- (instancetype)initWithTargetView:(UIView *)weakTargetView menus:(NSArray *)menus;
- (void)showOnTargetView;

@end

@interface FHPopupMenuItem : NSObject

@property (nonatomic, assign)   FHHouseType     houseType;
@property (nonatomic, assign)   BOOL       isSelected;
@property (nonatomic, copy)     FHPopupMenuItemClickBlock       itemClickBlock;
- (instancetype)initWithHouseType:(FHHouseType)ht isSelected:(BOOL)isSelected;

@end

@interface FHPopupMenuItemView : UIControl

@property (nonatomic, strong)   UILabel       *label;
@property (nonatomic, weak)     FHPopupMenuItem       *menuItem;

@end

NS_ASSUME_NONNULL_END
