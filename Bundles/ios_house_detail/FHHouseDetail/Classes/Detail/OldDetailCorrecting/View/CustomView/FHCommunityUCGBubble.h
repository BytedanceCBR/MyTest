//
// Created by zhulijun on 2019-06-25.
//

#import <Foundation/Foundation.h>


@interface FHCommunityUCGBubble : UIView
@property (nonatomic ,strong) UIColor *bacColor;
@property (nonatomic ,assign) CGFloat cornerRadius;
- (CGFloat)refreshWithAvatar:(NSString *)icon title:(NSString *)title color:(UIColor *)color;
@end
