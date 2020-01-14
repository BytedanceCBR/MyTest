//
//  FHUGCMessageView.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/12.
//

#import "FHUGCMessageView.h"
#import "Masonry.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "UIImageView+BDWebImage.h"
#import "TTBaseMacro.h"

#define iconWidth 30

@interface FHUGCMessageView ()

@property(nonatomic ,strong) UIImageView *rightArror;

@end

@implementation FHUGCMessageView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
        [self initConstraints];
    }
    return self;
}

- (void)initViews {
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 4;
    
    self.icon = [[UIImageView alloc] init];
    _icon.backgroundColor = [UIColor themeGray7];
    _icon.contentMode = UIViewContentModeScaleAspectFill;
    _icon.layer.masksToBounds = YES;
    _icon.layer.cornerRadius = iconWidth/2;
    [self addSubview:_icon];
    
    self.messageLabel = [self LabelWithFont:[UIFont themeFontMedium:14] textColor:[UIColor whiteColor]];
    _messageLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_messageLabel];
    
    self.rightArror = [[UIImageView alloc] init];
    _rightArror.image = [UIImage imageNamed:@"fh_ugc_arrow_right_black"];
    [self addSubview:_rightArror];
}

- (void)initConstraints {
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.left.mas_equalTo(self).offset(8);
        make.width.height.mas_equalTo(iconWidth);
    }];
    
    [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.left.mas_equalTo(self.icon.mas_right).offset(10);
        make.right.mas_equalTo(self.rightArror.mas_left).offset(-10);
        make.height.mas_equalTo(20);
    }];
    
    [self.rightArror mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.right.mas_equalTo(self).offset(-8);
        make.width.mas_equalTo(6);
        make.height.mas_equalTo(10);
    }];
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (void)refreshWithUrl:(NSString *)url messageCount:(NSInteger)messageCount {
    if(messageCount > 0){
        NSString *countStr = [NSString stringWithFormat:@"%ld",messageCount];
        if (messageCount > 99) {
            countStr = @"99+";
        }
        self.messageLabel.text = [NSString stringWithFormat:@"%@条新消息",countStr];
        if(!isEmptyString(url)){
            [self.icon bd_setImageWithURL:[NSURL URLWithString:url] placeholder:nil];
        }
    }
}

@end
