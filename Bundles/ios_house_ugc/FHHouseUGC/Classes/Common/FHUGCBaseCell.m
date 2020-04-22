//
//  FHUGCBaseCell.m
//  FHHouseUGC
//
//  Created by 张元科 on 2019/6/3.
//

#import "FHUGCBaseCell.h"

@implementation FHUGCBaseCell

// Cell装饰
- (UIImageView *)decorationImageView {
    if(!_decorationImageView) {
        _decorationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        _decorationImageView.contentMode = UIViewContentModeScaleAspectFit;
        _decorationImageView.hidden = YES;
        [self.contentView addSubview:_decorationImageView];
    }
    return _decorationImageView;
}

-(void)setCurrentData:(id)currentData {
    
    _currentData = currentData;
    
    // 设置Cell装饰，例如：置顶、精华
    if (![currentData isKindOfClass:[FHFeedUGCCellModel class]]) {
        return;
    }
    
    FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)currentData;
    cellModel.ischanged = NO;
    NSString *decorationImageUrlStr = cellModel.contentDecoration.url;
    BOOL isShowDecoration = cellModel.isStick && (decorationImageUrlStr.length > 0);
    self.decorationImageView.hidden = !(isShowDecoration);
    if(!cellModel.isCustomDecorateImageView && decorationImageUrlStr.length > 0) {
        [self.decorationImageView sd_setImageWithURL:[NSURL URLWithString:decorationImageUrlStr]];
    }
}


+ (Class)cellViewClass
{
    return [self class];
}

+ (NSString *)cellIdentifier {
    return NSStringFromClass([self cellViewClass]);
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.isFromDetail = NO;
    }
    return self;
}

- (void)refreshWithData:(id)data {
    // sub implements.........
}

+ (CGFloat)heightForData:(id)data {
    //默认返回cell的默认值44;
    return 44;
}

@end

// FHUGCBaseCollectionCell
@implementation FHUGCBaseCollectionCell

+ (Class)cellViewClass
{
    return [self class];
}

+ (NSString *)cellIdentifier {
    return NSStringFromClass([self cellViewClass]);
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)refreshWithData:(id)data {
    // sub implements.........
}

@end

