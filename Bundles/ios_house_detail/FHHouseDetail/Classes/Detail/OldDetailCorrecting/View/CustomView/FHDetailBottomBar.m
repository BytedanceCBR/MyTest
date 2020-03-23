//
//  FHDetailBottomBar.m
//  Pods
//
//  Created by liuyu on 2019/12/26.
//

#import "FHDetailBottomBar.h"
#import "masonry.h"
#import "UIFont+House.h"
#import "UIColor+Theme.h"
@interface FHDetailBottomBar()
@end
@implementation FHDetailBottomBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _showIM = NO;
    }
    return self;
}
- (void)refreshBottomBar:(FHDetailContactModel *)contactPhone contactTitle:(NSString *)contactTitle chatTitle:(NSString *)chatTitle {
    
}
- (void)startLoading {
    
}
- (void)stopLoading {
    
}

- (void)setBottomGroupChatBtn:(FHDetailUGCGroupChatButton *)bottomGroupChatBtn {
    _bottomGroupChatBtn = bottomGroupChatBtn;
    [bottomGroupChatBtn addTarget:self action:@selector(groupBtnClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)groupBtnClick:(UIButton *)btn {
    if (self.bottomBarGroupChatBlock) {
        self.bottomBarGroupChatBlock();
    }
}

@end

@interface FHDetailUGCGroupChatButton ()

@property (nonatomic, strong)   UIImageView       *bgView;
@property (nonatomic, strong)   UIImageView       *rightIcon;

@end

@implementation FHDetailUGCGroupChatButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"detail_ugc_group_chat_bg"]];
    [self addSubview:self.bgView];
    [self addSubview:self.titleLabel];
    self.rightIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"detail_ugc_group_chat_right"]];
    [self addSubview:self.rightIcon];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    [self.rightIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.titleLabel);
        make.right.mas_equalTo(self).offset(-10);
        make.width.height.mas_equalTo(10);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(18);
        make.left.mas_equalTo(self).offset(15);
        make.top.mas_equalTo(4);
        make.right.mas_equalTo(self.rightIcon.mas_left).offset(-5);
    }];
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.text = @"加入看盘群";
        _titleLabel.font = [UIFont themeFontSemibold:12];
        _titleLabel.textColor = [UIColor themeOrange4];
    }
    return _titleLabel;
}

@end
