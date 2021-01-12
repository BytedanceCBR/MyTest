#import "FHDetailNeighborhoodTitleView.h"
#import "FHUIAdaptation.h"
#import "UILabel+House.h"
#import "UIFont+House.h"
#import "UIColor+Theme.h"
#import "Masonry.h"
#import "UIImage+FIconFont.h"
#import "FHDetailMoreView.h"

@interface FHDetailNeighborhoodTitleView ()
@property (nonatomic, strong) UILabel *loadMore;
@property (nonatomic, strong) UIImageView *arrowsImg;
@property (nonatomic, strong) UILabel *label;
@end

@implementation FHDetailNeighborhoodTitleView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    _isShowLoadMore = NO;
    _label = [[UILabel alloc] init];
    _label.textColor = [UIColor themeGray1];
    _label.font = [UIFont themeFontMedium:16];
    [self addSubview:_label];
    
    _arrowsImg = [[UIImageView alloc] initWithImage:[FHDetailMoreView moreArrowImage]];
    _arrowsImg.hidden = YES;
    [self addSubview:_arrowsImg];
    
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(self);
        make.right.equalTo(self.arrowsImg.mas_left).offset(-10);
    }];
    
    [self.arrowsImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self);
        make.height.width.mas_equalTo(14);
        make.centerY.equalTo(self.label);
    }];
}

- (void)setIsShowLoadMore:(BOOL)isShowLoadMore {
    _isShowLoadMore = isShowLoadMore;
    _arrowsImg.hidden = !isShowLoadMore;
}

- (void)setTitleStr:(NSString *)titleStr {
    _titleStr = titleStr;
    self.label.text = titleStr;
}
@end
