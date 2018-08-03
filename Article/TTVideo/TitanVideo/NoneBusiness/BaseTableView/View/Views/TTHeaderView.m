

#import "TTHeaderView.h"

@implementation TTHeaderView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (BOOL)needUpdate
{
    return NO;
}

- (void)update:(id)data
{
    
}

- (void)doLayoutSubviews
{
    
}
@end
