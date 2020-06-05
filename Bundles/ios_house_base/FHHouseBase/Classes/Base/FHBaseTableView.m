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
        [self setupAttrs];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        [self setupAttrs];
    }
    return self;
}

-(void)setupAttrs
{
    if (@available(iOS 11.0, *)) {
        self.insetsContentViewsToSafeArea = NO;
        self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
