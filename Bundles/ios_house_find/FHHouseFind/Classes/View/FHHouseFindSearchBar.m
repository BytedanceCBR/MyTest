//
//  FHHouseFindSearchBar.m
//  Pods
//
//  Created by 张静 on 2019/1/2.
//

#import "FHHouseFindSearchBar.h"
#import "Masonry.h"
#import "UIFont+House.h"
#import "UIColor+Theme.h"
#import "UIViewAdditions.h"
#import "FHTextField.h"

@interface FHHouseFindSearchBar () <UITextFieldDelegate>

@property(nonatomic , strong) FHTextField *inputTextField;


@end

@implementation FHHouseFindSearchBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        [self setupUI];
    }
    return self;
}


- (FHTextField *)inputTextField
{
    if (!_inputTextField) {
        
        _inputTextField = [[FHTextField alloc] init];
        _inputTextField.borderStyle = UITextBorderStyleNone;
        _inputTextField.backgroundColor = [UIColor themeGrayPale];
        _inputTextField.font = [UIFont themeFontRegular:14];
        _inputTextField.textColor = [UIColor themeGray3];
        _inputTextField.delegate = self;
        _inputTextField.layer.cornerRadius = 4;
        _inputTextField.layer.masksToBounds = YES;
        _inputTextField.edgeInsets = UIEdgeInsetsMake(1, 0, 0, 0);
        UIImage *searchIcon = [UIImage imageNamed:@"nav_search_icon"];
        UIImageView *searchImgView = [[UIImageView alloc] initWithImage:searchIcon];
        searchImgView.frame = CGRectMake(0, 0, 12, 12);
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        [leftView addSubview:searchImgView];
        searchImgView.center = CGPointMake(leftView.width/2, leftView.height/2);
        leftView.backgroundColor = [UIColor clearColor];
        _inputTextField.leftView = leftView;
        _inputTextField.leftViewMode = UITextFieldViewModeAlways;
        
        
    }
    return _inputTextField;
}

- (void)setupUI
{
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.inputTextField];
    
    [_inputTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(@20);
        make.right.mas_equalTo(self).offset(-20);
        make.bottom.mas_equalTo(self);
        make.height.mas_equalTo(32);
    }];

}

- (void)setPlaceHolder:(NSString *)placeHolder
{
    if (placeHolder.length < 1) {
        return;
    }
    NSDictionary *attrDict = @{NSFontAttributeName:[UIFont themeFontRegular:12],
                               NSForegroundColorAttributeName:[UIColor themeGray3]
                               };
    NSAttributedString *attrPlaceHolder = [[NSAttributedString alloc] initWithString:placeHolder attributes:attrDict];
    _inputTextField.attributedPlaceholder = attrPlaceHolder;
}

- (NSString *)placeHolder
{
    if (_inputTextField.attributedText.string.length > 0) {
        return _inputTextField.attributedText.string;
    }
    return _inputTextField.placeholder;
}

- (void)setInputText:(NSString *)inputText
{
    if (inputText) {
        NSDictionary *attrDict = @{NSFontAttributeName:[UIFont themeFontRegular:12],
                                   NSForegroundColorAttributeName:[UIColor themeBlack]
                                   };
        NSAttributedString *attrText = [[NSAttributedString alloc] initWithString:inputText attributes:attrDict];
        _inputTextField.attributedText = attrText;
    }else{
        _inputTextField.attributedText = nil;
        _inputTextField.text = nil;
    }
    
}

- (NSString *)inputText
{
    return _inputTextField.text;
}

#pragma mark - uitextfield delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (_tapInputBar) {
        _tapInputBar();
    }
    return NO;
}
@end
