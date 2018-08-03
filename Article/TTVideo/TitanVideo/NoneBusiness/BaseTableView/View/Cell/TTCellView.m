
#import "TTCellView.h"

@implementation TTCellView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)renderView
{
    
}

- (void)fillContent
{
    
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    
}

+ (CGFloat)cellHeightWithEntity:(TTBaseCellEntity *)cellEntity indexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (void)willBeginReuse
{
    
}

- (void)tt_cellAction:(NSUInteger)action object:(id)object callbackBlock:(TTCellActionCallback)callbackBlock
{
    if ([self.action_delegate respondsToSelector:@selector(tt_cellAction:object:callbackBlock:)]) {
        [self.action_delegate tt_cellAction:action object:object callbackBlock:callbackBlock];
    }
}
@end
