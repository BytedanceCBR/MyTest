//
//  FHRentArticleListNotifyBarView.m
//  FHHouseRent
//
//  Created by 春晖 on 2018/11/29.
//

#import "FHRentArticleListNotifyBarView.h"

@implementation FHRentArticleListNotifyBarView

- (void)hideIfNeeds
{
    // 注意，0.3s与TTRefreshView收起列表的动画时间一致
    CGRect frame = self.frame;
    [UIView animateWithDuration:0.3f animations:^{
        self.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, 0);
    } completion:^(BOOL finished) {
        self.hidden = YES;
        self.frame = frame;
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
