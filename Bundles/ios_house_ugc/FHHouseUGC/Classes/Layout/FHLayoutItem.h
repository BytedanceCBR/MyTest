//
//  FHLayoutItem.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/12/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHLayoutItem : NSObject

@property(nonatomic ,assign) CGFloat top;
@property(nonatomic ,assign) CGFloat left;
@property(nonatomic ,assign) CGFloat width;
@property(nonatomic ,assign) CGFloat height;

@property(nonatomic ,assign, readonly) CGFloat right;
@property(nonatomic ,assign, readonly) CGFloat bottom;

+ (FHLayoutItem *)layoutWithTop:(CGFloat)top
                         left:(CGFloat)left
                        width:(CGFloat)width
                       height:(CGFloat)height;

+ (void)updateView:(UIView *)view withLayout:(FHLayoutItem *)layout;

@end

NS_ASSUME_NONNULL_END
