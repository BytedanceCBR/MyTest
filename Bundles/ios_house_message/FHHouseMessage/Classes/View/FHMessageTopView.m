//
//  FHMessageTopView.m
//  FHHouseMessage
//
//  Created by xubinbin on 2020/7/27.
//

#import "FHMessageTopView.h"
#import "Masonry.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "FHUtils.h"

@interface FHMessageTopView()

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIButton *chatButton;
@property (nonatomic, strong) UIButton *systemMessageButton;
@property (nonatomic, strong) UIView *chatRedPointView;
@property (nonatomic, strong) UIView *systemMessageRedPointView;


@end

@implementation FHMessageTopView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
        [self initConstraints];
    }
    return self;
}

- (void)setupUI {
    self.containerView = [[UIView alloc] init];
    [self addSubview:_containerView];
    self.containerView.backgroundColor = [UIColor themeGray7];
    self.containerView.layer.cornerRadius = 15;
    self.containerView.layer.masksToBounds = YES;
    
    self.chatButton = [self getButtonWithTitle:@"微聊" andTag:1];
    [self.containerView addSubview:_chatButton];
    self.chatButton.selected = YES;
    [self updateColor:self.chatButton];
    
    self.systemMessageButton = [self getButtonWithTitle:@"通知" andTag:2];
    [self.containerView addSubview:_systemMessageButton];
    self.systemMessageButton.selected = NO;
    [self updateColor:self.systemMessageButton];
    
    self.chatRedPointView = [[UIView alloc] init];
    [self.chatButton addSubview:_chatRedPointView];
    self.chatRedPointView.layer.cornerRadius = 5;
    self.chatRedPointView.layer.masksToBounds = YES;
    self.chatRedPointView.backgroundColor = [UIColor themeOrange1];
    self.chatRedPointView.hidden = YES;
    
    self.systemMessageRedPointView = [[UIView alloc] init];
    [self.systemMessageButton addSubview:_systemMessageRedPointView];
    self.systemMessageRedPointView.layer.cornerRadius = 5;
    self.systemMessageRedPointView.layer.masksToBounds = YES;
    self.systemMessageRedPointView.backgroundColor = [UIColor themeOrange1];
    self.systemMessageRedPointView.hidden = YES;
}

- (void)initConstraints {
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.bottom.mas_equalTo(-7);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(176);
    }];
    [self.chatButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.containerView);
        make.left.mas_equalTo(2);
        make.height.mas_equalTo(26);
        make.width.mas_equalTo(86);
    }];
    [self.systemMessageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.containerView);
        make.right.mas_equalTo(-2);
        make.height.mas_equalTo(26);
        make.width.mas_equalTo(86);
    }];
    [self.chatRedPointView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(10);
        make.bottom.mas_equalTo(-14);
        make.right.mas_equalTo(-15);
    }];
    [self.systemMessageRedPointView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(10);
        make.bottom.mas_equalTo(-14);
        make.right.mas_equalTo(-15);
    }];
}

- (UIButton *)getButtonWithTitle:(NSString *)title andTag:(NSInteger)tag {
    UIButton *btn = [[UIButton alloc] init];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont themeFontRegular:14];
    [btn setTitleColor:[UIColor themeGray2] forState:UIControlStateNormal];
    [btn setBackgroundImage:[FHUtils createImageWithColor:[UIColor themeGray7]] forState:UIControlStateNormal];
    btn.adjustsImageWhenHighlighted = NO;
    btn.layer.masksToBounds = YES;
    btn.layer.cornerRadius = 13;
    btn.tag = tag;
    btn.selected = NO;
    [btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (void)clickBtn:(UIButton *)button {
    if (!button.selected) {
        self.chatButton.selected = !self.chatButton.selected;
        self.systemMessageButton.selected = !self.systemMessageButton.selected;
        [self updateColor:self.chatButton];
        [self updateColor:self.systemMessageButton];
    }
}

- (void)updateColor:(UIButton *)btn {
    if (btn.selected) {
        [btn setTitleColor:[UIColor themeGray1] forState:UIControlStateNormal];
        [btn setBackgroundImage:[FHUtils createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    } else {
        [btn setTitleColor:[UIColor themeGray2] forState:UIControlStateNormal];
        [btn setBackgroundImage:[FHUtils createImageWithColor:[UIColor themeGray7]] forState:UIControlStateNormal];
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
