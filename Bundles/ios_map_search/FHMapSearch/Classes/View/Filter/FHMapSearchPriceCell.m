//
//  FHMapSearchPriceCell.m
//  DemoFunTwo
//
//  Created by 春晖 on 2019/7/10.
//  Copyright © 2019 chunhui. All rights reserved.
//

#import "FHMapSearchPriceCell.h"
#import <FHCommonUI/UIFont+House.h>
#import <FHCommonUI/UIColor+Theme.h>
#import <Masonry/Masonry.h>


@interface FHMapSearchPriceCell ()<UITextFieldDelegate>

@property(nonatomic , strong) UITextField *lowerTextField;
@property(nonatomic , strong) UITextField *higherTextField;
@property(nonatomic , strong) UIView *splitLine;

@end

@implementation FHMapSearchPriceCell

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.lowerTextField = [self textField:@"最低价(万)"];
        self.higherTextField = [self textField:@"最高价(万)"];
        
        self.splitLine = [[UIView alloc] init];
        self.splitLine.backgroundColor = [UIColor themeGray6];
        _splitLine.layer.cornerRadius = 0.5;
        _splitLine.layer.masksToBounds = YES;
        
        [self.contentView addSubview:_lowerTextField];
        [self.contentView addSubview:_higherTextField];
        [self.contentView addSubview:_splitLine];
        
        [self initContraints];
    }
    return self;
}

-(UITextField *)textField:(NSString *)placeholder
{
    UITextField *tf = [[UITextField alloc]init];
    
    tf.layer.cornerRadius = 4;
    tf.backgroundColor = [UIColor themeGray7];
    
    tf.keyboardType = UIKeyboardTypeNumberPad;
    tf.textAlignment = NSTextAlignmentLeft;
    tf.textColor = [UIColor themeGray1];
    tf.font = [UIFont themeFontRegular:14];
    
    tf.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 1)];
    tf.rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 1)];
    tf.leftViewMode = UITextFieldViewModeAlways;
    tf.rightViewMode = UITextFieldViewModeAlways;
    
    tf.delegate = self;
    
    tf.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder
                                                               attributes:@{NSFontAttributeName:[UIFont themeFontRegular:14],
                                                                            NSForegroundColorAttributeName:[UIColor themeGray4]
                                                                            }];
    
    return tf;
}

-(void)initContraints
{
    [self.splitLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(11, 1));
    }];
    
    [self.lowerTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.mas_equalTo(self.contentView);
        make.right.mas_equalTo(self.splitLine.mas_left).offset(-6);
    }];
    
    [self.higherTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.mas_equalTo(self.contentView);
        make.left.mas_equalTo(self.splitLine.mas_right).offset(6);
    }];
}

-(BOOL)isInEditing
{
    return [self.lowerTextField isFirstResponder] || [self.higherTextField isFirstResponder];
}

-(void)updateWithLowerPlaceholder:(NSString *)lowPrice higherPlaceholder:(NSString *)highPrice
{
    self.lowerTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:lowPrice
                                                                                attributes:@{NSFontAttributeName:[UIFont themeFontRegular:14],
                                                                                             NSForegroundColorAttributeName:[UIColor themeGray4]
                                                                                             }];
    self.higherTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:highPrice
                                                                                 attributes:@{NSFontAttributeName:[UIFont themeFontRegular:14],
                                                                                              NSForegroundColorAttributeName:[UIColor themeGray4]
                                                                                              }];
}

-(void)updateWithLowerPrice:(NSString *)lowPrice higherPrice:(NSString *)highPrice
{
    
    if (!(lowPrice && highPrice)) {
        //至少有一个为nil
        self.lowerTextField.text = lowPrice;
        self.higherTextField.text = highPrice;
        return;
    }
    
    if (lowPrice.integerValue > highPrice.integerValue ) {
        NSString *tempNum = lowPrice;
        lowPrice = highPrice;
        highPrice = tempNum;
        
    }
    if (lowPrice.integerValue > 0) {
        self.lowerTextField.text = [NSString stringWithFormat:@"%d",lowPrice.intValue];
    }else if (lowPrice.length > 0){
        self.lowerTextField.text = lowPrice;
    }else{
        self.lowerTextField.text = nil;
    }
    if (highPrice.integerValue > 0) {
        self.higherTextField.text = [NSString stringWithFormat:@"%d",highPrice.intValue];
    }else if (highPrice.length > 0){
        self.higherTextField.text = highPrice;
    }else{
        self.higherTextField.text = nil;
    }
    
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (self.delegate) {
        
        NSString *number = nil;
        if (textField.text.length > 0) {
            number = textField.text;//@(textField.text integerValue]);
        }
        
        if (textField == self.lowerTextField) {
            [self.delegate updateLowerPrice:number inCell:self];
        }
        if (textField == self.higherTextField) {
            [self.delegate updateHigherPrice:number inCell:self];
        }
    }
    
}


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *result =  [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ((result.length > textField.text.length) && ![string isEqualToString:[@(string.integerValue) description]]) {
        //输入非数字
        return NO;
    }
    
    if (result.length >= 9) {
        return NO;
    }
    
    if (result.length == 0) {
        return YES;
    }
    
    //    if ([result isEqualToString:[NSString stringWithFormat:@"%d",result.intValue]]) {
    //        return YES;
    //    }
    
    if ([self.delegate respondsToSelector:@selector(priceDidChange:inCell:)]) {
        [self.delegate priceDidChange:result inCell:self];
    }
    
    return YES;
    
}


@end
