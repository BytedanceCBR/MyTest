//
//  TTTouchContext.h
//  Article
//
//  Created by carl on 2017/3/2.
//
//

#import <Foundation/Foundation.h>

@protocol TTAdCellLayoutInfo
- (NSDictionary *)adCellLayoutInfo;
@end

/**
 记录一次点击行为
 */
@interface TTTouchContext : NSObject

- (instancetype)initWithTargetView:(UIView *)targetView;

/**
 点击点在画布中的坐标
 */
@property (nonatomic, assign) CGPoint touchPoint;

/**
 被点击的视图
 */
@property (nonatomic, weak) UIView *targetView;

- (NSDictionary *)touchInfo;

/**
 点击行为在父子视图上的装换

 @param view 最终转换后的视图
 @return 返回新的点击描述
 */
- (instancetype)toView:(UIView *)view;

+ (NSString *)format2JSON:(NSDictionary *)dict;

@end
