//
// Created by zhulijun on 2019-07-03.
//

#import "FHDetailHeaderViewNoMargin.h"


#import "UILabel+House.h"

@interface FHDetailHeaderViewNoMargin ()

@property (nonatomic, strong)   UILabel       *loadMore;
@property (nonatomic, strong)   UIImageView       *arrowsImg;

@end

@implementation FHDetailHeaderViewNoMargin

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
    _label = [UILabel createLabel:@"" textColor:@"" fontSize:18];
    _label.textColor = [UIColor themeGray1];
    _label.font = [UIFont themeFontMedium:18];
    [self addSubview:_label];

    _loadMore = [UILabel createLabel:@"查看更多" textColor:@"" fontSize:14];
    _loadMore.textColor = [UIColor themeGray3];
    _loadMore.textAlignment = NSTextAlignmentRight;
    _loadMore.hidden = YES;
    [self addSubview:_loadMore];

    _arrowsImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrowicon-feed-4"]];
    _arrowsImg.hidden = YES;
    [self addSubview:_arrowsImg];

    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(self.loadMore.mas_left).offset(-10);
        make.top.mas_equalTo(self);
        make.height.mas_equalTo(26);
    }];

    [self.arrowsImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self).offset(-17);
        make.height.width.mas_equalTo(18);
        make.centerY.mas_equalTo(self.label.mas_centerY);
    }];
    [self.loadMore mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.label.mas_centerY);
        make.height.mas_equalTo(14);
        make.width.mas_equalTo(80);
        make.right.mas_equalTo(self.arrowsImg.mas_left);
    }];
}

- (void)setIsShowLoadMore:(BOOL)isShowLoadMore {
    _isShowLoadMore = isShowLoadMore;
    _loadMore.hidden = !isShowLoadMore;
    _arrowsImg.hidden = !isShowLoadMore;
}

@end
