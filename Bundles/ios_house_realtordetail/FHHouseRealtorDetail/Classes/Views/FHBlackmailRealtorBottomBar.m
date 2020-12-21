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
@property (nonatomic, strong) UIImageView *hintImageView;
@property (nonatomic, strong) UIView   *hintContainer;
@property (nonatomic, strong) UIButton *otherRealtorBtn;
@property (nonatomic, strong) UILabel  *hintLabel;
@end

@implementation FHBlackmailRealtorBottomBar
- (UIView *)hintContainer {
    if(!_hintContainer) {
        _hintContainer = [UIView new];
        _hintContainer.backgroundColor = [UIColor themeOrange2];
    }
    return _hintContainer;
}
- (UIButton *)otherRealtorBtn {
    if(!_otherRealtorBtn) {
        _otherRealtorBtn = [UIButton buttonWithType: UIButtonTypeCustom];
        _otherRealtorBtn.layer.cornerRadius = 20;
        _otherRealtorBtn.layer.masksToBounds = YES;
        _otherRealtorBtn.titleLabel.font =[UIFont themeFontRegular:16];
        _otherRealtorBtn.titleLabel.textColor = [UIColor themeWhite];
        [_otherRealtorBtn setTitle:@"找其他经纪人" forState:UIControlStateNormal];
        [_otherRealtorBtn setTitle:@"找其他经纪人" forState:UIControlStateHighlighted];
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
-(UIImageView *)hintImageView {
    if(!_hintImageView) {
        _hintImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hint_image_icon"]];
    }
    return _hintImageView;
}
- (UILabel *)hintLabel {
    if(!_hintLabel) {
        _hintLabel = [UILabel new];
        _hintLabel.font = [UIFont themeFontRegular:12];
        _hintLabel.textColor = [UIColor themeOrange1];
        _hintLabel.numberOfLines = 0;
        _hintLabel.backgroundColor = [UIColor clearColor];
    }
    return _hintLabel;
}

- (instancetype)init {
    if(self = [super init]) {
        
        [self.hintContainer addSubview:self.hintImageView];
        [self.hintContainer addSubview:self.hintLabel];
        [self addSubview:self.hintContainer];
        [self addSubview:self.otherRealtorBtn];
        
        [self.hintImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.width.mas_equalTo(15);
            make.left.equalTo(self.hintContainer).offset(20);
            make.top.equalTo(self.hintContainer).offset(11);
        }];
        
        [self.hintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.hintContainer).offset(10);
            make.bottom.equalTo(self.hintContainer).offset(-10);
            make.left.equalTo(self.hintImageView.mas_right).offset(10);
            make.right.equalTo(self.hintContainer).offset(-15);
        }];
        
        [self.hintContainer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.left.right.equalTo(self);
            make.bottom.equalTo(self.otherRealtorBtn.mas_top).offset(-12);
        }];
        
        [self.otherRealtorBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(15);
            make.right.equalTo(self).offset(-15);
            make.bottom.equalTo(self).offset(-12);
            make.height.mas_equalTo(40);
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
