//
//  WDListAnswerCellBottomView.m
//  AKWDPlugin
//
//  Created by 张元科 on 2019/6/14.
//

#import "WDListAnswerCellBottomView.h"
#import <Masonry.h>
#import "UIFont+House.h"
#import <UIImageView+BDWebImage.h>
#import "FHCommonDefines.h"
#import "UIColor+Theme.h"

@interface WDListAnswerCellBottomView ()

@property (nonatomic, strong)   WDListAnswerCellBottomButton       *commentBtn;
@property (nonatomic, strong)   WDListAnswerCellBottomButton       *followBtn;

@end

@implementation WDListAnswerCellBottomView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor whiteColor];
    // 评论
    self.commentBtn = [[WDListAnswerCellBottomButton alloc] init];
    self.commentBtn.icon.image = [UIImage imageNamed:@"f_ask_message_noraml"];
    self.commentBtn.textLabel.text = @"0";
    [self addSubview:self.commentBtn];
    // 点赞
    self.followBtn = [[WDListAnswerCellBottomButton alloc] init];
    self.followBtn.icon.image = [UIImage imageNamed:@"f_ask_favorite_noraml"];// f_ask_favorite_selected
    self.followBtn.textLabel.text = @"0";
    [self addSubview:self.followBtn];
    
    [self setupConstraints];
}

- (void)setupConstraints {
    [self.followBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self);
        make.right.mas_equalTo(self).offset(-20);
        make.bottom.mas_equalTo(self);
    }];
    [self.commentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self);
        make.right.mas_equalTo(self.followBtn.mas_left).offset(-20);
        make.bottom.mas_equalTo(self);
    }];
}

@end

// WDListAnswerCellBottomButton
@interface WDListAnswerCellBottomButton ()

@end

@implementation WDListAnswerCellBottomButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
        self.followed = NO;
    }
    return self;
}

- (void)setupUI {
    self.icon = [[UIImageView alloc] init];
    [self addSubview:_icon];
    
    self.textLabel = [self labelWithFont:[UIFont themeFontRegular:14] textColor:[UIColor themeGray1]];
    [self addSubview:_textLabel];
    
    [self setupConstraints];
}


- (void)setupConstraints {
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(self);
        make.width.height.mas_equalTo(20);
    }];
    
    [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self);
        make.left.mas_equalTo(self.icon.mas_right).mas_offset(4);
        make.right.mas_equalTo(self);
        make.height.mas_equalTo(20);
    }];
}

- (UILabel *)labelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

@end
