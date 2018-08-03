//
//  TTMomentEnterCell.m
//  Article
//
//  Created by yuxin on 11/13/15.
//
//

#import "TTMomentEnterCell.h"

@implementation TTMomentEnterCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib {
    [super awakeFromNib];
    self.titleLeftMargin.constant = [TTDeviceUIUtils tt_padding:30.f/2];
    if (![SSCommonLogic transitionAnimationEnable]) {
        self.backgroundSelectedColorThemeKey = @"BackgroundSelectedColor1";
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.titleLeftMargin.constant = [TTDeviceUIUtils tt_padding:30.f/2];
}

- (void)setCellImageName:(NSString*)imageName {
    
    [self.momentView setCellImageName:imageName];
}
@end
