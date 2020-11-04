//
//  FHHouseHeaderView.m
//  FHHouseMessage
//
//  Created by 谢思铭 on 2019/2/12.
//

#import "FHHouseHeaderView.h"
#import "UIFont+House.h"
#import "Masonry.h"
#import "UIColor+Theme.h"
#import "TTDeviceHelper.h"

@interface FHHouseHeaderView()
@property (nonatomic, strong) UIView *dateViewSection;
@end

@implementation FHHouseHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]){
        [self initViews];
    }
    return self;
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self initViews];
    }
    return self;
}

- (void)initViews {
    
    self.contentView.backgroundColor = [UIColor themeWhite];
    
    self.dateViewSection = [UIView new];
    self.dateViewSection.backgroundColor = [UIColor themeGray7];
    [self.contentView addSubview:self.dateViewSection];
    [self.dateViewSection mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.contentView);
        make.height.mas_equalTo(50);
    }];
    
    self.dateView = [[UIView alloc] init];
    _dateView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
    _dateView.layer.cornerRadius = 4;
    _dateView.layer.masksToBounds = YES;
    [self.dateViewSection addSubview:_dateView];
    [self.dateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(20);
        make.height.mas_equalTo(20);
        make.centerX.equalTo(self);
    }];
    
    self.dateLabel = [self LabelWithFont:[UIFont themeFontRegular:12] textColor:[UIColor whiteColor]];
    [_dateView addSubview:_dateLabel];
    [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.dateView.mas_left).offset(10);
        make.right.mas_equalTo(self.dateView.mas_right).offset(-10);
        make.center.mas_equalTo(self.dateView);
    }];
    
    self.contentLabel = [self LabelWithFont:[UIFont themeFontRegular:14] textColor:[UIColor themeGray1]];
    _contentLabel.numberOfLines = 2;
    _contentLabel.lineBreakMode = UILineBreakModeTailTruncation;
    [self.contentView addSubview:_contentLabel];
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).offset(20);
        make.right.mas_equalTo(self.contentView).offset(-20);
        make.top.mas_equalTo(self.dateViewSection.mas_bottom).offset(10);
        make.bottom.mas_equalTo(self.contentView).offset(-10);
    }];
    
    self.bottomLine = [[UIView alloc] init];
    _bottomLine.backgroundColor = [UIColor themeGray6];
    [self.contentView addSubview:_bottomLine];
    [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.contentView);
        make.height.mas_equalTo(TTDeviceHelper.ssOnePixel);
    }];
}

-(UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor
{
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

@end
