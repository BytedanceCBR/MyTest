
#import "TTVideoFloatCell.h"
#import "TTCellConfigure.h"

@implementation TTVideoFloatCell
@dynamic customContentView;
@dynamic cellEntity;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryType = UITableViewCellAccessoryNone;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor colorWithHexString:kFloatVideoCellBackgroundColor];
    }
    return self;
}

+ (UIEdgeInsets)cellInsets
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (TTCellConfigure *)listCellConfigure{
    TTCellConfigure *configure = [[TTCellConfigure alloc] init];
    configure.contentViewClass = [TTVideoFloatContentView class];
    configure.cellInsets = [[self class] cellInsets];

    return configure;
}
//模板修改
+ (CGFloat)cellHeightWithEntity:(TTVideoFloatCellEntity *)cellEntity indexPath:(NSIndexPath *)indexPath{
    return [TTVideoFloatContentView cellHeightWithEntity:cellEntity indexPath:indexPath];
}

- (NSString *)videoID
{
    return [[self.cellEntity.article videoDetailInfo] valueForKey:@"video_id"];
}

- (void)removeMovieView
{
    [self.customContentView removeMovieView];
}

- (void)showPlayIcon:(BOOL)show
{
    [self.customContentView showPlayIcon:show];
}

- (void)showBackgroundImage:(BOOL)show
{
    [self.customContentView showBackgroundImage:show];
}

- (void)addMovieView:(UIView *)movieView
{
    [self.customContentView addMovieView:movieView];
}

- (TTDetailModel *)detailModel
{
    return self.customContentView.cellEntity.detailModel;
}

- (void)immerseHalf
{
    [self.customContentView immerseHalf];
}

- (void)unImmerseHalf
{
    [self.customContentView unImmerseHalf];
}

- (void)immerseAll
{
    [self.customContentView immerseAll];
}
- (void)unImmerseAll
{
    [self.customContentView unImmerseAll];
}
- (void)willBeginReuse
{
    [self.customContentView willBeginReuse];
}

- (BOOL)isImmersed
{
    return [self.customContentView isImmersed];
}

- (UIView *)animationToView
{
    return [self.customContentView animationToView];
}
@end
