//
//  FHNeighborhoodDetailRelatedHouseMoreCell.m
//  FHHouseDetail
//
//  Created by xubinbin on 2020/12/10.
//

#import "FHNeighborhoodDetailRelatedHouseMoreCell.h"
#import "Masonry.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "UILabel+BTDAdditions.h"

@implementation FHNeighborhoodDetailRelatedHouseMoreCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backView = [[UIView alloc] init];
        [self addSubview:self.backView];
        self.backView.backgroundColor = [UIColor colorWithHexStr:@"#fafafa"];
        self.backView.layer.cornerRadius = 4;
        [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(10);
            make.right.mas_equalTo(-10);
            make.bottom.mas_equalTo(-16);
            make.top.mas_equalTo(0);
        }];
        
        self.textLabel = [[UILabel alloc] init];
        self.textLabel.font = [UIFont themeFontRegular:16];
        self.textLabel.textColor = [UIColor themeGray1];
        [self addSubview:self.textLabel];
        [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.backView);
            make.centerX.mas_equalTo(self.backView).offset(-8);
            make.height.mas_equalTo(19);
        }];
        
        self.arrowsImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"neighborhood_detail_v3_arrow_icon"]];
        [self addSubview:self.arrowsImg];
        [self.arrowsImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.textLabel.mas_right).offset(4);
            make.centerY.mas_equalTo(self.textLabel);
            make.width.height.mas_equalTo(12);
        }];
    }
    return self;
}

- (void)refreshWithTitle:(NSString *)text {
    self.textLabel.text = text;
    CGFloat width = [self.textLabel btd_widthWithHeight:19];
    [self.textLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(width);
    }];
}

@end
