//
//  TTDetailNatantHeaderPaddingView.m
//  Article
//
//  Created by Ray on 16/4/8.
//
//

#import "TTDetailNatantHeaderPaddingView.h"
#import "TTUISettingHelper.h"

#define kPaddingHeight 15
@interface TTDetailNatantHeaderPaddingView()
@property(nonatomic, retain, nullable)UIView * topLineView;
@property(nonatomic, retain, nullable)UIView * bottomLineView;
@end

@implementation TTDetailNatantHeaderPaddingView

- (id)initWithWidth:(CGFloat)width{
    self = [super initWithFrame:CGRectMake(0, 0, width, kPaddingHeight)];
    if (self) {
        [self reloadThemeUI];
        self.backgroundColors = [TTUISettingHelper detailViewBackgroundColors];
    }
    return self;
}

+ (float)viewHeight{
    return kPaddingHeight;
}

@end
