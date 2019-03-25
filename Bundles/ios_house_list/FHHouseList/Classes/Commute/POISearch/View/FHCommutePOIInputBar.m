//
//  FHCommutePOIInputBar.m
//  FHHouseList
//
//  Created by 春晖 on 2019/3/22.
//

#import "FHCommutePOIInputBar.h"
#import <FHCommonUI/UIColor+Theme.h>
#import <FHCommonUI/UIFont+House.h>
#import <FHHouseBase/FHCommonDefines.h>
#import <Masonry/Masonry.h>


#define BAR_HEIGHT 32
#define BAR_BOTTOM_MARGIN 6
#define BAR_RIGHT_MARGIN  60
#define BAR_CANCEL_MARGIN 10

@interface FHCommutePOIInputBar ()<UITextFieldDelegate>

@property(nonatomic , strong) UITextField *searechField;
@property(nonatomic , strong) UIButton *cancelButton;
@property(nonatomic , strong) UIView *clearView;

@end

@implementation FHCommutePOIInputBar

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _searechField = [[UITextField alloc] init];
        _searechField.delegate = self;
        _searechField.backgroundColor =  [UIColor themeGray6];
        _searechField.borderStyle = UITextBorderStyleNone;
        _searechField.layer.cornerRadius = 4;
        _searechField.layer.masksToBounds = YES;
        _searechField.returnKeyType = UIReturnKeySearch;
        _searechField.textColor = [UIColor themeGray1];
        _searechField.font = [UIFont themeFontRegular:14];
        
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage * img = SYS_IMG(@"search_delete");
        [rightButton setImage:img forState:UIControlStateNormal];
        [rightButton addTarget:self action:@selector(onClearAction) forControlEvents:UIControlEventTouchUpInside];
        rightButton.frame = CGRectMake(0, (BAR_HEIGHT - 24)/2, 24, 24);
        UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, BAR_HEIGHT)];
        [rightView addSubview:rightButton];
        _searechField.rightView = rightView;
        _clearView = rightView;
        _clearView.hidden = YES;
        
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 1)];
        leftView.backgroundColor = [UIColor clearColor];
        _searechField.leftView = leftView;
        _searechField.leftViewMode = UITextFieldViewModeAlways;
        
        _searechField.clearButtonMode = UITextFieldViewModeNever;
        _searechField.rightViewMode = UITextFieldViewModeAlways;
        
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        _cancelButton.titleLabel.font = [UIFont themeFontRegular:16];
        [_cancelButton setTitleColor:[UIColor themeGray1] forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(onCancelAction) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_searechField];
        [self addSubview:_cancelButton];
        
        [_searechField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(HOR_MARGIN);
            make.bottom.mas_equalTo(self).offset(-BAR_BOTTOM_MARGIN);
            make.right.mas_equalTo(self).offset(-BAR_RIGHT_MARGIN);
            make.height.mas_equalTo(BAR_HEIGHT);
        }];
        
        [_cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self).offset(-10);
            make.left.mas_equalTo(self.searechField.mas_right).offset(10);
            make.centerY.mas_equalTo(self.searechField);
            make.height.mas_equalTo(BAR_HEIGHT + 2*BAR_BOTTOM_MARGIN);
        }];
        
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(BOOL)becomeFirstResponder
{
    return [_searechField becomeFirstResponder];
}

-(BOOL)canBecomeFirstResponder
{
    return [_searechField canBecomeFirstResponder];
}

- (BOOL)resignFirstResponder
{
    return [_searechField resignFirstResponder];
}

-(void)setDelegate:(id<FHCommutePOIInputBarDelegate>)delegate
{
    _delegate = delegate;
    _searechField.delegate = delegate;
}

-(void)setText:(NSString *)text
{
    self.searechField.text = text;
}

-(NSString *)text
{
    return _searechField.text;
}

-(void)setPlaceHolder:(NSString *)placeHolder
{
    if (!IS_EMPTY_STRING(placeHolder)) {
        NSDictionary *dict = @{NSFontAttributeName:[UIFont themeFontRegular:14],
                               NSForegroundColorAttributeName:[UIColor themeGray3]
                               };
        NSAttributedString *attrPlaceholder = [[NSAttributedString alloc] initWithString:placeHolder attributes:dict] ;
        self.searechField.attributedPlaceholder = attrPlaceholder;
    }else{
        self.searechField.placeholder = placeHolder;
    }
}

-(NSString *)placeHolder
{
    return _searechField.placeholder;
}

-(void)showClear:(BOOL)show
{
    self.clearView.hidden = !show;
}

-(void)onClearAction
{
    self.clearView.hidden = YES;
    self.searechField.text = nil;
    if ([self.delegate respondsToSelector:@selector(textFieldClear)]) {
        [self.delegate textFieldClear];
    }
}

-(void)onCancelAction
{
    if ([self.delegate respondsToSelector:@selector(inputBarCancel)]) {
        [self.delegate inputBarCancel];
    }
}


@end
