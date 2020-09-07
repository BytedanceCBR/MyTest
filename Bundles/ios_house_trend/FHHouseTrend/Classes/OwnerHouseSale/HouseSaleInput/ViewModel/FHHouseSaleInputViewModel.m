//
//  FHHouseSaleInputViewModel.m
//  FHHouseTrend
//
//  Created by 谢思铭 on 2020/9/6.
//

#import "FHHouseSaleInputViewModel.h"

@interface FHHouseSaleInputViewModel ()

@property(nonatomic , weak) FHHouseSaleInputController *viewController;
@property(nonatomic , weak) FHHouseSaleInputView *view;

@end

@implementation FHHouseSaleInputViewModel

- (instancetype)initWithView:(FHHouseSaleInputView *)view controller:(FHHouseSaleInputController *)viewController;
{
    self = [super init];
    if (self) {
        _view = view;
//        _view.delegate = self;
//        _view.areaItemView.textField.delegate = self;
        _viewController = viewController;
//        _infoModel = [[FHPriceValuationHistoryDataHistoryHouseListHouseInfoHouseInfoDictModel alloc] init];
        
        //埋点
//        [self addGoDetailTracer];
    }
    return self;
}

- (void)viewWillAppear {
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShowNotifiction:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHideNotifiction:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)viewWillDisappear {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -- textFieldDidChange

- (void)textFieldDidChange:(NSNotification *)notification {
//    UITextField *textField = (UITextField *)notification.object;
//    NSString *text = textField.text;
//
//    if(text.length > 0){
//        unichar single = [text characterAtIndex:(text.length - 1)];
//        if(single == "."){
//            text = [text substringToIndex:(text.length - 1)];
//        }
//    }
//    self.infoModel.squaremeter = text;
//    [self checkEvaluateEnabled];
}

//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
//    //埋点
//    [self addClickOptionsTracer:self.view.areaItemView.titleLabel.text];
//    
//    return YES;
//}
//
//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
//    BOOL isHaveDian = NO;
//    if ([textField.text rangeOfString:@"."].location == NSNotFound){
//        isHaveDian = NO;
//    }else{
//        isHaveDian = YES;
//    }
//    if ([string length] > 0){
//        unichar single = [string characterAtIndex:0];//当前输入的字符
//        if ((single >= '0' && single <= '9') || single == '.'){
//            //首字母不能为小数点
//            if([textField.text length] == 0){
//                if(single == '.'){
//                    [textField.text stringByReplacingCharactersInRange:range withString:@""];
//                    return NO;
//                }
//            }
//            //输入的字符是否是小数点
//            if (single == '.'){
//                if(!isHaveDian){
//                    isHaveDian = YES;
//                    return YES;
//                }else{
//                    [textField.text stringByReplacingCharactersInRange:range withString:@""];
//                    return NO;
//                }
//            }else{
//                if (isHaveDian) {//存在小数点
//                    //判断小数点的位数
//                    NSRange ran = [textField.text rangeOfString:@"."];
//                    if(range.location > ran.location){
//                        //控制小数点后面的字符数不大于2个
//                        if ([textField.text length] - ran.location <= 2){
//                            return YES;
//                        }else{
//                            return NO;
//                        }
//                    }else{
//                        //控制小数点前面的字符数不大于6个
//                        if (ran.location < 6){
//                            return YES;
//                        }else{
//                            return NO;
//                        }
//                    }
//                }else{
//                    //控制无小数点时字符数不大于6个
//                    if([textField.text length] >= 6){
//                        return NO;
//                    }
//                    return YES;
//                }
//                
//            }
//            
//        }else{//输入的数据格式不正确
//            [textField.text stringByReplacingCharactersInRange:range withString:@""];
//            return NO;
//        }
//    }else{
//        return YES;
//    }
//}

#pragma mark - 键盘通知

- (void)keyboardWillShowNotifiction:(NSNotification *)notification {
    if(_isHideKeyBoard){
        return;
    }
}

- (void)keyboardWillHideNotifiction:(NSNotification *)notification {
    
}

@end
