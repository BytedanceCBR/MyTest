#import "FHDetailNeighborhoodTitleView.h"
#import "FHUIAdaptation.h"
#import "UILabel+House.h"
#import "UIFont+House.h"
#import "UIColor+Theme.h"
#import "Masonry.h"

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
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self);
        make.right.mas_equalTo(self.arrowsImg.mas_left).offset(AdaptOffset(-10));
        make.top.bottom.mas_equalTo(self);
    }];
    
    _arrowsImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrowicon-feed-4"]];
    _arrowsImg.hidden = YES;
    [self addSubview:_arrowsImg];
    [self.arrowsImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self).offset(AdaptOffset(-12));
        make.height.width.mas_equalTo(AdaptOffset(20));
        make.centerY.mas_equalTo(self.label.mas_centerY);
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
