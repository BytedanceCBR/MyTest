//
//  TTPopTipsView.h
//  TTLive
//
//  Created by xuzichao on 16/3/29.
//  Copyright © 2016年 Nick Yu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSThemed.h"

@class TTPopTipItem;

typedef enum {
    TTPopTipsMessage,//示例：直播室提醒关注的界面
    TTPopTipsAction //示例：直播室分享和关注按钮合体
}TTPopTipViewType;


@interface TTPopTipsView : SSThemedView

/**
 *  建立视图
 *
 *  @param items 数据TTPopTipItem
 */
- (void)setPopViewWithItem:(NSArray *)items type:(TTPopTipViewType)type;

/**
 *  关闭
 *
 *  @param animate 是否动画
 */
- (void)dismissAnimate:(BOOL)animate;

/**
 *  展开
 *
 *  @param animate 是否动画
 */
- (void)showAnimate:(BOOL)animate;

/**
 *  边框颜色
 *
 *  @param borderColor 
 */
- (void)setBorderColor:(UIColor *)borderColor;

/**
 *  显示状态
 *
 *  @return 布尔值
 */
- (BOOL)dismiss;

/**
 *  修改item数据
 *
 *
 */

- (void)replaceItemByTitle:(NSString *)title withItem:(TTPopTipItem *)item;


@end



typedef void(^TTPopTipsItemBlock)(void);

@interface TTPopTipItem : NSObject

@property (nonatomic,assign) TTPopTipViewType type;
@property (nonatomic,strong) TTPopTipsItemBlock block;
@property (nonatomic,copy) NSString *tipDesc;
@property (nonatomic,copy) NSString *tipBtnTitle;
@property (nonatomic,strong) UIImage *tipActionImage;

@end
