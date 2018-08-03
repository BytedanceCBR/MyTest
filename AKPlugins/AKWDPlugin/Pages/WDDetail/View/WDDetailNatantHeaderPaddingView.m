//
//  WDDetailNatantHeaderPaddingView.m
//  Article
//
//  Created by Ray on 16/4/8.
//
//

#import "WDDetailNatantHeaderPaddingView.h"


#define kPaddingHeight 15
@interface WDDetailNatantHeaderPaddingView()
@property(nonatomic, retain, nullable)UIView * topLineView;
@property(nonatomic, retain, nullable)UIView * bottomLineView;
@end

@implementation WDDetailNatantHeaderPaddingView

- (id)initWithWidth:(CGFloat)width{
    self = [super initWithFrame:CGRectMake(0, 0, width, kPaddingHeight)];
    if (self) {
        [self reloadThemeUI];
        self.backgroundColors = @[ [UIColor colorWithHexString:@"ffffff"],[UIColor colorWithHexString:@"252525"] ];
    }
    return self;
}

+ (float)viewHeight{
    return kPaddingHeight;
}

@end
