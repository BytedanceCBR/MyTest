//
//  FHMyJoinAllNeighbourhoodCell.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/7/22.
//

#import "FHMyJoinAllNeighbourhoodCell.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "Masonry.h"

@interface FHMyJoinAllNeighbourhoodCell ()

@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UIImageView *icon;

@end

@implementation FHMyJoinAllNeighbourhoodCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self initView];
        [self initConstains];
    }
    return self;
}

- (void)refreshWithData:(id)data {
    [self setShowText:NO];
}

- (void)initView {
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 4;
    
    self.icon = [[UIImageView alloc] init];
    _icon.image = [UIImage imageNamed:@"fh_ugc_follow_right_icon"];
    [self.contentView addSubview:_icon];
    
    self.titleLabel = [self LabelWithFont:[UIFont themeFontRegular:12] textColor:[UIColor themeGray3]];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.numberOfLines = 0;
    [_titleLabel sizeToFit];
    [self.contentView addSubview:_titleLabel];
}

- (NSDictionary *)titleLabelAttributes {
    NSMutableDictionary *attributes = @{}.mutableCopy;
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.minimumLineHeight = 14;
    paragraphStyle.maximumLineHeight = 14;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    [attributes setValue:paragraphStyle forKey:NSParagraphStyleAttributeName];
    return [attributes copy];
}

- (void)initConstains {
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(3);
        make.centerX.mas_equalTo(self.contentView);
        make.width.height.mas_equalTo(12);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(12);
        make.height.mas_equalTo(72);
        make.top.mas_equalTo(self.contentView).offset(20);
        make.centerX.mas_equalTo(self.contentView);
    }];
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (void)setShowText:(BOOL)isLeave {
    NSString *str = @"";
    if(isLeave){
        str = @"松开查看";
    }else{
        str = @"全部圈子";
    }
    NSAttributedString *aStr = [[NSAttributedString alloc] initWithString:str attributes:[self titleLabelAttributes]];
    self.titleLabel.attributedText = aStr;
}

@end
