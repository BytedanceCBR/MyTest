//
//  WDBaseCellView.m
//  wenda
//
//  Created by xuzichao on 2017/2/8.
//

#import "WDBaseCellView.h"
#import "WDBaseCell.h"

@implementation WDBaseCellView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)identifier {
    self = [self initWithFrame:frame];
    self.reuseIdentifier = identifier;
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)refreshUI
{
    
}

- (void)refreshWithData:(id)data
{

}

- (id)cellData
{
    return nil;
}

- (void)fontSizeChanged
{

}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{

}

- (void)didSelected:(id)data apiParam:(NSString *)apiParam {}

- (void)didEndDisplaying:(UIView *)listView {}

- (void)willDisplaying:(UIView *)listView {}

+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)width listType:(NSInteger)listType;
{
    return 0;
}

- (void)willDisplay {}
- (void)willAppear {}

- (void)willDisappear {}

- (void)didDisappear {}

- (void)didAppear {}

@end
