//
//  FHBaseTableView.m
//  FHHouseBase
//
//  Created by 春晖 on 2019/8/13.
//

#import "FHBaseTableView.h"

@implementation FHBaseTableView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self setInsetContentArea];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        [self setInsetContentArea];
    }
    return self;
}

-(void)setInsetContentArea
{
    if (@available(iOS 11.0, *)) {
        self.insetsContentViewsToSafeArea = NO;
    }
}

-(void)setInsetsContentViewsToSafeArea:(BOOL)insetsContentViewsToSafeArea
{
    [super setInsetsContentViewsToSafeArea:insetsContentViewsToSafeArea];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
