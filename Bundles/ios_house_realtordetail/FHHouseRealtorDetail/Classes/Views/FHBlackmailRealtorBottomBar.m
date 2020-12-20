//
//  FHBlackmailRealtorBottomBar.m
//  FHHouseRealtorDetail
//
//  Created by wangzhizhou on 2020/12/20.
//

#import "FHBlackmailRealtorBottomBar.h"
#import <FHCommonUI/UIFont+House.h>
#import <FHCommonUI/UIColor+Theme.h>
#import <ReactiveObjC.h>
#import <Masonry.h>
#import <ByteDanceKit.h>
#import "FHCommonDefines.h"

@interface FHBlackmailRealtorBottomBar()
@property (nonatomic, strong) UIButton *otherRealtorBtn;
@property (nonatomic, strong) UILabel  *hintLabel;
@end

@implementation FHBlackmailRealtorBottomBar
- (UIButton *)otherRealtorBtn {
    if(!_otherRealtorBtn) {
        _otherRealtorBtn = [UIButton buttonWithType: UIButtonTypeCustom];
        _otherRealtorBtn.layer.cornerRadius = 20;
        _otherRealtorBtn.layer.masksToBounds = YES;
        [_otherRealtorBtn setTitle:@"其他经纪人" forState:UIControlStateNormal];
        [_otherRealtorBtn setTitle:@"其他经纪人" forState:UIControlStateHighlighted];
        _otherRealtorBtn.backgroundColor = [UIColor themeOrange4];
        
        @weakify(self);
        [[[_otherRealtorBtn rac_signalForControlEvents:UIControlEventTouchUpInside] deliverOnMainThread] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            if(self.btnActionBlock) {
                self.btnActionBlock();
            }
        }];
    }
    return _otherRealtorBtn;
}

- (UILabel *)hintLabel {
    if(!_hintLabel) {
        _hintLabel = [UILabel new];
        _hintLabel.font = [UIFont themeFontRegular:14];
        _hintLabel.textColor = [UIColor themeGray1];
        _hintLabel.numberOfLines = 0;
    }
    return _hintLabel;
}

- (instancetype)init {
    if(self = [super init]) {
        
        self.backgroundColor = [UIColor themeWhite];
        
        [self addSubview:self.otherRealtorBtn];
        [self addSubview:self.hintLabel];
        
        [self.otherRealtorBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(10);
            make.right.equalTo(self).offset(-10);
            make.top.equalTo(self).offset(10);
            make.bottom.equalTo(self.hintLabel.mas_top).offset(-10);
            make.height.mas_equalTo(40);
        }];
        
        [self.hintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.otherRealtorBtn);
            make.bottom.equalTo(self).offset(-10);
        }];
    }
    return self;
}

- (void)show:(BOOL)isShow WithHint:(NSString *)hint btnAction:(void (^)(void))actionBlock {
    self.hidden = !isShow;
    self.hintLabel.text = hint;
    self.btnActionBlock = actionBlock;
}
@end
