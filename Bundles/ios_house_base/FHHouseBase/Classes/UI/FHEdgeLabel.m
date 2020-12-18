//
//  FHEdgeLabel.m
//  FHHouseBase
//
//  Created by 谢飞 on 2020/10/28.
//

#import "FHEdgeLabel.h"

@implementation FHEdgeLabel

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)drawTextInRect:(CGRect)rect {
    // 边距，上左下右
    UIEdgeInsets insets = {0, 5, 0, 5};
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

@end
