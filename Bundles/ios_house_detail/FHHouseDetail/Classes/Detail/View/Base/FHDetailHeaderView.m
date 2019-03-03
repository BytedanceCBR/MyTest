//
//  FHDetailHeaderView.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/14.
//

#import "FHDetailHeaderView.h"
#import <Masonry.h>
#import "UIFont+House.h"
#import <UIImageView+BDWebImage.h>
#import "FHCommonDefines.h"
#import "UILabel+House.h"

@interface FHDetailHeaderView ()

@property (nonatomic, strong)   UILabel       *loadMore;
@property (nonatomic, strong)   UIImageView       *arrowsImg;

@end

@implementation FHDetailHeaderView

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
    _label = [UILabel createLabel:@"" textColor:@"#081f33" fontSize:18];
    _label.font = [UIFont themeFontMedium:18];
    [self addSubview:_label];
    
    _loadMore = [UILabel createLabel:@"查看更多" textColor:@"#8a9299" fontSize:14];
    _loadMore.textAlignment = NSTextAlignmentRight;
    _loadMore.hidden = YES;
    [self addSubview:_loadMore];
    
    _arrowsImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrowicon-feed-4"]];
    _arrowsImg.hidden = YES;
    [self addSubview:_arrowsImg];
    
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(self.loadMore.mas_left).offset(-10);
        make.top.mas_equalTo(20);
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