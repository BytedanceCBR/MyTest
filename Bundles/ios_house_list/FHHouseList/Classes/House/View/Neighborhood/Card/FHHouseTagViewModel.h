//
//  FHHouseTagViewModel.h
//  ABRInterface
//
//  Created by bytedance on 2020/11/10.
//

#import "FHHouseNewComponentViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseTagViewModel : FHHouseNewComponentViewModel

@property (nonatomic, assign) CGFloat maxWidth;

- (NSString *)text;
- (UIColor *)textColor;
- (UIFont *)textFont;
- (UIColor *)backgroundColor;
- (UIColor *)topBackgroundColor;
- (UIColor *)bottomBackgroundColor;
- (BOOL)isGradient;
- (CGFloat)tagWidth;
- (CGFloat)tagHeight;

- (instancetype)initWithModel:(id)model;

@end

NS_ASSUME_NONNULL_END
