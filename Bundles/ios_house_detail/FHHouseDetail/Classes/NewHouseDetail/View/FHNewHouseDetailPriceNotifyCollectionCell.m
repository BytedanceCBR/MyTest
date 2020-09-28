//
//  FHNewHouseDetailPriceNotifyCollectionCell.m
//  AKCommentPlugin
//
//  Created by bytedance on 2020/9/6.
//

#import "FHNewHouseDetailPriceNotifyCollectionCell.h"
#import <ByteDanceKit/UIDevice+BTDAdditions.h>

@interface FHNewHouseDetailPriceNotifyCollectionCell ()
@property (nonatomic, strong) UIView *priceBgView;
@property (nonatomic, strong) UIButton *priceChangedNotify;
@property (nonatomic, strong) UIView *verticalLineView;
@property (nonatomic, strong) UIButton *openNotify;
@end

@implementation FHNewHouseDetailPriceNotifyCollectionCell

+ (CGSize)cellSizeWithData:(id)data width:(CGFloat)width {
    return CGSizeMake(width, 65);
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.priceBgView = [[UIView alloc] init];
        self.priceBgView.backgroundColor = [UIColor colorWithHexString:@"#fffaf0"];
        self.priceBgView.layer.cornerRadius = 25;
        self.priceBgView.layer.masksToBounds = YES;
        [self.contentView addSubview:self.priceBgView];
        [self.priceBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.right.mas_equalTo(-15);
            make.height.mas_equalTo(45);
            make.top.equalTo(0);
            make.bottom.mas_equalTo(-20);
        }];
        
        _priceChangedNotify = [UIButton buttonWithType:UIButtonTypeCustom];
        _priceChangedNotify.titleLabel.font = [UIFont themeFontRegular:16];
        
        UIImage *priceImg = ICON_FONT_IMG(16, @"\U0000e67e", [UIColor colorWithHexString:@"#9c6d43"]);
        UIImage *openImage = ICON_FONT_IMG(16, @"\U0000e68e", [UIColor colorWithHexString:@"#9c6d43"]);

        [_priceChangedNotify setImage:priceImg forState:UIControlStateNormal];
        [_priceChangedNotify setImage:priceImg forState:UIControlStateHighlighted];
        
        [_priceChangedNotify setTitle:@"变价通知" forState:UIControlStateNormal];
        [_priceChangedNotify setTitleColor:[UIColor colorWithHexString:@"#9c6d43"] forState:UIControlStateNormal];
        _priceChangedNotify.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        [self.contentView addSubview:_priceChangedNotify];
        [_priceChangedNotify addTarget:self action:@selector(priceChangedNotifyActionClick) forControlEvents:UIControlEventTouchUpInside];
        [_priceChangedNotify mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.priceBgView);
            make.left.equalTo(self.priceBgView);
            make.right.equalTo(self.priceBgView.mas_centerX);
        }];
        
        
        _verticalLineView = [UIView new];
        _verticalLineView.backgroundColor = [UIColor colorWithHexString:@"#ffe7d2"];
        [self.contentView addSubview:_verticalLineView];
        [_verticalLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.priceChangedNotify);
            make.bottom.equalTo(self.priceChangedNotify);
            make.left.equalTo(self.priceChangedNotify.mas_right);
            make.width.mas_equalTo([UIDevice btd_onePixel]);
        }];
        
        _openNotify = [UIButton buttonWithType:UIButtonTypeCustom];
        _openNotify.titleLabel.font = [UIFont themeFontRegular:16];
        [_openNotify setImage:openImage forState:UIControlStateNormal];
        [_openNotify setImage:openImage forState:UIControlStateHighlighted];
                                                    
        [_openNotify setTitle:@"开盘通知" forState:UIControlStateNormal];
        [_openNotify setTitleColor:[UIColor colorWithHexString:@"#9c6d43"] forState:UIControlStateNormal];
        _openNotify.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        [_openNotify addTarget:self action:@selector(openNotifyActionClick) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_openNotify];
        [_openNotify mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.priceChangedNotify);
            make.left.equalTo(self.priceBgView.mas_centerX);
            make.right.equalTo(self.priceBgView);
        }];
    }
    return self;
}

- (void)refreshWithData:(id)data
{
    if (self.currentData == data || ![data isKindOfClass:[FHNewHouseDetailPriceNotifyCellModel class]]) {
        return;
    }
    self.currentData = data;
//    FHNewHouseDetailPriceNotifyCellModel *model = (FHNewHouseDetailPriceNotifyCellModel *)data;
}

- (void)openNotifyActionClick {
    if (self.openNotifyActionBlock) {
        self.openNotifyActionBlock();
    }
}

- (void)priceChangedNotifyActionClick {
    if (self.priceChangedNotifyActionBlock) {
        self.priceChangedNotifyActionBlock();
    }
}

- (NSArray *)elementTypes
{
    return @[@"price_notice",@"openning_notice"];
}

@end

@implementation FHNewHouseDetailPriceNotifyCellModel

@end
