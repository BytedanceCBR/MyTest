//
//  TTCategoryItem.h
//  TTUIWidget
//
//  Created by lizhuoli on 2018/3/22.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, TTCategoryItemBadgeStyle) {
    TTCategoryItemBadgeStyleNone,
    TTCategoryItemBadgeStylePoint,
    TTCategoryItemBadgeStyleNumber
};

/** 频道项 */
@interface TTCategoryItem : NSObject

/** 红点数量 */
@property (nonatomic, assign) NSInteger badgeNum;
/** 红点类型 */
@property (nonatomic, assign) TTCategoryItemBadgeStyle badgeStyle;
/** 频道名称 */
@property (nonatomic, copy) NSString * _Nonnull title;

@end
