//
//  FHMessageEditView.m
//  FHHouseMessage
//
//  Created by xubinbin on 2020/7/28.
//

#import "FHMessageEditView.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "Masonry.h"

@interface FHMessageEditView()

@property (nonatomic, weak) UIButton *deleteButton;

@end

@implementation FHMessageEditView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    UIButton *btn = [self getButtonWithTitle:@"删除" andTag:1];
    [self addSubview:btn];
    self.deleteButton = btn;
    [self.deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(0);
        make.right.mas_equalTo(10);
        make.width.mas_equalTo(self.mas_width);
    }];
}

- (UIButton *)getButtonWithTitle:(NSString *)title andTag:(NSInteger)tag {
    UIButton *btn = [[UIButton alloc] init];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont themeFontRegular:16];
    [btn setTitleColor:[UIColor themeWhite] forState:UIControlStateNormal];
    btn.tag = tag;
    [btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (void)clickBtn:(UIButton *)btn {
    if (btn.tag == 1 && self.clickDeleteBtn) {
        self.clickDeleteBtn();
    }
}

@end
