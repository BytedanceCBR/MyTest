
#import "TTBaseCell.h"
#import "TTCellView.h"

@interface TTBaseCell ()<TTBaseCellAction>
@property (nonatomic) TTCellConfigure *configure;
@end
@implementation TTBaseCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self setBackgroundColor:[UIColor whiteColor]];
        
        UIView *view = [[UIView alloc] initWithFrame:self.bounds];
        self.selectedBackgroundView = view;
    }
    return self;
}

- (CGRect)contentFrame
{
    CGRect frame = CGRectMake(_insets.left, _insets.top, self.frame.size.width - _insets.left - _insets.right, _cellEntity.heightOfCell > 0 ? _cellEntity.heightOfCell  - _insets.top - _insets.bottom : [[self class] fixCellHeight] - _insets.top - _insets.bottom);
    return frame;
}

- (void)willBeginReuse
{
    [self.customContentView willBeginReuse];
}

- (void)fillContent:(TTBaseCellEntity *)cellEntity indexPath:(NSIndexPath *)indexPath
{
    _indexPath = indexPath;
    _cellEntity = cellEntity;
    
    if (!_customContentView) {
        _configure = [self listCellConfigure];

        Class contentViewClass = nil;
        if (_configure) {
            _insets = _configure.cellInsets;
            contentViewClass = _configure.contentViewClass;
        }
        else
        {
            _insets = cellEntity.cellInsets;
            contentViewClass = cellEntity.contentViewClass;
        }
        if (!_customContentView) {
            _customContentView = [[contentViewClass alloc] initWithFrame:[self contentFrame]];
            _customContentView.backgroundColor = self.backgroundColor;
            _customContentView.cellEntity = cellEntity;
            _customContentView.indexPath = self.indexPath;
            [_customContentView renderView];
            [self.contentView addSubview:_customContentView];
        }
    }
    _customContentView.frame = [self contentFrame];
    _customContentView.cellEntity = cellEntity;
    _customContentView.indexPath = indexPath;
    _customContentView.action_delegate = self;
    [_customContentView fillContent];
}

- (void)tt_cellAction:(NSUInteger)action object:(id)object callbackBlock:(TTCellActionCallback)callbackBlock
{
    if ([self.action_delegate respondsToSelector:@selector(tt_cellAction:object:callbackBlock:)]) {
        [self.action_delegate tt_cellAction:action object:object callbackBlock:callbackBlock];
    }
}

- (TTCellConfigure *)listCellConfigure
{
    return nil;
}

+ (CGFloat)heightOfContent:(TTBaseCellEntity *)cellEntity
{
    return 0;
}

+ (CGFloat)cellHeightWithEntity:(TTBaseCellEntity *)cellEntity indexPath:(NSIndexPath *)indexPath{
    return [cellEntity.contentViewClass cellHeightWithEntity:cellEntity indexPath:indexPath];
}

+ (NSInteger)fixCellHeight
{
    return 44;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _customContentView.frame = [self contentFrame];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if ([self.customContentView isKindOfClass:[TTCellView class]]) {
        [self.customContentView setHighlighted:selected animated:animated];
    }
}

+ (NSCache *)shadowImageCache
{
    static NSCache *cache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [[NSCache alloc] init];
    });
    
    return cache;
}

@end
