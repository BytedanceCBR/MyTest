//
//  FHFastQAMobileNumberView.m
//  FHHouseFind
//
//  Created by 春晖 on 2019/6/18.
//

#import "FHFastQAMobileNumberView.h"
#import <FHCommonUI/UIFont+House.h>
#import <FHCommonUI/UIColor+Theme.h>
#import <Masonry/Masonry.h>

@interface FHFastQAMobileNumberView ()

@property(nonatomic , strong) UILabel *titleLabel;
@property(nonatomic , strong) UIView *phoneBgView;
@property(nonatomic , strong) UITextField *phoneTextField;
@property(nonatomic , strong) UILabel *tipLabel;

@end

@implementation FHFastQAMobileNumberView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.text = @"免费获取专家解答";
        _titleLabel.textColor = [UIColor themeGray1];
        _titleLabel.font = [UIFont themeFontRegular:14];
        
        _phoneBgView = [[UIView alloc]init];
        _phoneBgView.layer.cornerRadius = 4;
        _phoneBgView.layer.masksToBounds = YES;
        _phoneBgView.backgroundColor = RGB(0xf4, 0xf5, 0xf6);
                
        _phoneTextField = [[UITextField alloc]init];
        _phoneTextField.borderStyle = UITextBorderStyleNone;
        _phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
        _phoneTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _phoneTextField.font = [UIFont themeFontRegular:14];
        _phoneTextField.textColor = [UIColor themeGray1];
        _phoneTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"填写手机号" attributes:@{NSFontAttributeName:[UIFont themeFontRegular:14],NSForegroundColorAttributeName:[UIColor themeGray3]}];
        [_phoneBgView addSubview:_phoneTextField];
        
        _tipLabel = [[UILabel alloc]init];
        _tipLabel.text = @"*我们将通过短信或电话的方式提供解答";
        _tipLabel.font = [UIFont themeFontRegular:14];
        _tipLabel.textColor = [UIColor themeGray3];
        
        [self addSubview:_titleLabel];
        [self addSubview:_phoneBgView];
        [self addSubview:_tipLabel];
        
        [self initConstraints];
    }
    return self;
}

-(void)initConstraints
{
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        make.height.mas_equalTo(20);
    }];
    
    [_phoneBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(10);
        make.height.mas_equalTo(37);
    }];
    
    [_phoneTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.mas_equalTo(self.phoneBgView);
        make.left.mas_equalTo(15);
    }];
    
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self);
        make.top.mas_equalTo(self.phoneBgView.mas_bottom).offset(5);
        make.height.mas_equalTo(16);
    }];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
