//
//  FHHouseFindPriceCell.m
//  FHHouseFind
//
//  Created by 春晖 on 2019/2/12.
//

#import "FHHouseFindPriceCell.h"
#import <FHCommonUI/UIFont+House.h>
#import <FHCommonUI/UIColor+Theme.h>
#import <Masonry/Masonry.h>


@interface FHHouseFindPriceCell()<UITextFieldDelegate>

@property(nonatomic , strong) UITextField *lowerTextField;
@property(nonatomic , strong) UITextField *higherTextField;
@property(nonatomic , strong) UIView *splitLine;

@end

@implementation FHHouseFindPriceCell

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        self.lowerTextField = [self textField:@"最低价"];
        self.higherTextField = [self textField:@"最高价"];
        
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
    tf.textColor = [UIColor themeBlack];
    tf.font = [UIFont themeFontRegular:14];
    
    tf.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 6, 1)];
    tf.rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 6, 1)];
    tf.leftViewMode = UITextFieldViewModeAlways;
    tf.rightViewMode = UITextFieldViewModeAlways;
    
    tf.delegate = self;
    
    tf.placeholder = placeholder;
    
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

-(void)updateWithLowerPrice:(NSNumber *)lowPrice higherPrice:(NSNumber *)highPrice
{

    if (!(lowPrice && highPrice)) {
        //至少有一个为nil
        if (!lowPrice) {
            self.lowerTextField.text = nil;
        }
        if (!highPrice) {
            self.higherTextField.text = nil;
        }
        return;
    }
    
    if (lowPrice.integerValue > highPrice.integerValue ) {
        NSNumber *tempNum = lowPrice;
        lowPrice = highPrice;
        highPrice = tempNum;
        
        if (lowPrice.integerValue > 0) {
            self.lowerTextField.text = [NSString stringWithFormat:@"%d",lowPrice.intValue];
        }else{
            self.lowerTextField.text = nil;
        }
        if (highPrice.integerValue > 0) {
            self.higherTextField.text = [NSString stringWithFormat:@"%d",highPrice.intValue];
        }else{
            self.higherTextField.text = nil;
        }
    }
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (self.delegate) {
        
        NSNumber *number = nil;
        if (textField.text.length > 0) {
            number = @([textField.text integerValue]);
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
    if (result.length >= 9) {
        return NO;
    }
    
    if (result.length == 0) {
        return YES;
    }
    
    if ([result isEqualToString:[NSString stringWithFormat:@"%d",result.intValue]]) {
        return YES;
    }
    
    return NO;
    
}

@end
