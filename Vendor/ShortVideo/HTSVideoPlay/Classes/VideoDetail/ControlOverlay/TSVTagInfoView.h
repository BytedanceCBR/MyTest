//
//  TSVTagInfoView.h
//  HTSVideoPlay
//
//  Created by 王双华 on 2017/10/13.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TSVTagInfoViewStyle) {
    TSVTagInfoViewStyleDefault,
    TSVTagInfoViewStyleRelationship,
    TSVTagInfoViewStyleActivity,
    TSVTagInfoViewStyleNewDetail,
    TSVTagInfoViewStyleChallenge,
};

@interface TSVTagInfoView : UIView

@property (nonatomic, assign) TSVTagInfoViewStyle style;

- (instancetype)initWithNightThemeEnabled:(BOOL)enabled;

- (void)refreshTagWithText:(NSString *)text;
- (void)addTarget:(id)target action:(SEL)action;

- (CGFloat)originalContainerWidth;
+ (CGFloat)maxContainerWidth;

@end
