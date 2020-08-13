//
//  FHMyJoinNeighbourhoodCell.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/12.
//

#import "FHMyJoinNeighbourhoodCell.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "Masonry.h"
#import "UIImageView+BDWebImage.h"
#import "FHUGCModel.h"
#import "UIImageView+fhUgcImage.h"

#define iconWidth 50

@interface FHMyJoinNeighbourhoodCell ()

@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *descLabel;
@property(nonatomic, strong) UIImageView *icon;

@end

@implementation FHMyJoinNeighbourhoodCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
        [self initConstains];
    }
    return self;
}

- (void)refreshWithData:(id)data {
    if([data isKindOfClass:[FHUGCScialGroupDataModel class]]){
        FHUGCScialGroupDataModel *model = (FHUGCScialGroupDataModel *)data;
        NSString *text = model.socialGroupName;
        _titleLabel.text = [self titleString:text];
        _descLabel.text = model.countText;
        
        [self.icon bd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholder:nil];
        
    }
}

- (void)initView {
    self.backgroundColor = [UIColor whiteColor];
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 4;
    
    self.icon = [[UIImageView alloc] init];
    _icon.contentMode = UIViewContentModeScaleAspectFill;
    _icon.layer.masksToBounds = YES;
    _icon.layer.cornerRadius = 4;
    _icon.backgroundColor = [UIColor themeGray7];
    _icon.layer.borderWidth = 0.5;
    _icon.layer.borderColor = [[UIColor themeGray6] CGColor];
    [self.contentView addSubview:_icon];
    
    self.titleLabel = [self LabelWithFont:[UIFont themeFontRegular:14] textColor:[UIColor themeGray1]];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.numberOfLines = 2;
    [self.contentView addSubview:_titleLabel];
    
    self.descLabel = [self LabelWithFont:[UIFont themeFontRegular:10] textColor:[UIColor themeGray3]];
    _descLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_descLabel];
}

- (void)initConstains {
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(15);
        make.centerX.mas_equalTo(self.contentView);
        make.width.height.mas_equalTo(iconWidth);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.icon.mas_bottom).offset(5);
        make.left.mas_equalTo(self.contentView).offset(10);
        make.right.mas_equalTo(self.contentView).offset(-10);
    }];
    
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom);
        make.left.mas_equalTo(self.contentView).offset(10);
        make.right.mas_equalTo(self.contentView).offset(-10);
        make.height.mas_equalTo(14);
    }];
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    label.layer.masksToBounds = YES;
    label.backgroundColor = [UIColor whiteColor];
    return label;
}

//针对小区的标题显示做特殊处理
- (NSString *)titleString:(NSString *)text {
    NSMutableString *str = [text mutableCopy];
    if(str.length <= 6){
        return str;
    }
    
    NSInteger topLength = str.length - str.length/2;
    if(topLength > 7){
        topLength = 7;
    }
    
    [str insertString:@"\n" atIndex:topLength];
    
    return str;
}

@end
