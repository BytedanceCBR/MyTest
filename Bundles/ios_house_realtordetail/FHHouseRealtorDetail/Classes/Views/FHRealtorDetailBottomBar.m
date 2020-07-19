//
//  FHRealtorDetailBottomBar.m
//  FHHouseRealtorDetail
//
//  Created by liuyu on 2020/7/17.
//

#import "FHRealtorDetailBottomBar.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "UIDevice+BTDAdditions.h"
#import "FHLoadingButton.h"
#import "Masonry.h"
@interface FHRealtorDetailBottomBar()
@property(nonatomic,strong) UIButton *imChatBtn;
@property(nonatomic,strong) FHLoadingButton *contactBtn;
@end
@implementation FHRealtorDetailBottomBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createUI];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)createUI {
    CGFloat btnWidth = ([UIScreen mainScreen].bounds.size.width -32 -12)/2;
    [self addSubview:self.contactBtn];
    [self.contactBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.right.mas_equalTo(self).offset(-16);
        make.width.mas_equalTo(btnWidth);
        make.height.mas_equalTo(40);
    }];
    [self addSubview:self.imChatBtn];
    [self.imChatBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.mas_equalTo(self).offset(16);
        make.width.mas_equalTo(btnWidth);
        make.height.mas_equalTo(40);
    }];
}

- (FHLoadingButton *)contactBtn
{
    if (!_contactBtn) {
        _contactBtn = [[FHLoadingButton alloc]init];
        [_contactBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_contactBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        if ([UIDevice btd_isIPhoneXSeries]) {
            _contactBtn.titleLabel.font = [UIFont themeFontRegular:14];
        } else {
            _contactBtn.titleLabel.font = [UIFont themeFontRegular:16];
        }
        [_contactBtn setTitle:@"电话咨询" forState:UIControlStateNormal];
        [_contactBtn setTitle:@"电话咨询" forState:UIControlStateHighlighted];
        _contactBtn.layer.cornerRadius = 22;
        // 阴影颜色
        _contactBtn.layer.shadowColor = [UIColor colorWithHexStr:@"#fe5500"].CGColor;
        // 阴影偏移量 默认为(0,3)
        _contactBtn.layer.shadowOffset = CGSizeMake(0, 8);
        // 阴影透明度
        _contactBtn.layer.shadowOpacity = .2;
        _contactBtn.layer.shadowRadius = 6;
        _contactBtn.backgroundColor =[UIColor colorWithHexStr:@"#fe5500"];
        [_contactBtn addTarget:self action:@selector(clickPhone:) forControlEvents:UIControlEventTouchDown];
     
    }
    return _contactBtn;
}

- (UIButton *)imChatBtn {
    if (!_imChatBtn) {
        _imChatBtn = [[UIButton alloc] init];
        _imChatBtn.layer.cornerRadius = 22;
        _imChatBtn.layer.shadowColor = [UIColor colorWithHexStr:@"#ff9629"].CGColor;
        _imChatBtn.layer.shadowOffset = CGSizeMake(0, 8);
        _imChatBtn.layer.shadowOpacity = .2 ;
        _imChatBtn.layer.shadowRadius = 6;
        _imChatBtn.backgroundColor = [UIColor colorWithHexStr:@"#ff9629"];
        if ([UIDevice btd_isIPhoneXSeries]) {
            _imChatBtn.titleLabel.font = [UIFont themeFontRegular:14];
        } else {
            _imChatBtn.titleLabel.font = [UIFont themeFontRegular:16];
        }
        [_imChatBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_imChatBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [_imChatBtn setTitle:@"在线联系" forState:UIControlStateNormal];
        [_imChatBtn setTitle:@"在线联系" forState:UIControlStateHighlighted];
        [_imChatBtn addTarget:self action:@selector(clickIm:) forControlEvents:UIControlEventTouchDown];
    }
    return _imChatBtn;
}

- (void)clickIm:(UIButton *)sender {
    if (self.imAction) {
        self.imAction();
    }
}

- (void)clickPhone:(UIButton *)sender {
    if (self.phoneAction) {
        self.phoneAction();
    }
}
@end
