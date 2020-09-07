//
//  FHHouseSaleInputViewModel.m
//  FHHouseTrend
//
//  Created by 谢思铭 on 2020/9/6.
//

#import "FHHouseSaleInputViewModel.h"
#import "FHHouseSaleInputModel.h"

@interface FHHouseSaleInputViewModel ()<FHHouseSaleInputViewDelegate>

@property(nonatomic , weak) FHHouseSaleInputController *viewController;
@property(nonatomic , weak) FHHouseSaleInputView *view;
@property(nonatomic , strong) FHHouseSaleInputModel *inputModel;

@end

@implementation FHHouseSaleInputViewModel

- (instancetype)initWithView:(FHHouseSaleInputView *)view controller:(FHHouseSaleInputController *)viewController;
{
    self = [super init];
    if (self) {
        _view = view;
        _view.delegate = self;
//        _view.areaItemView.textField.delegate = self;
        _viewController = viewController;
        _inputModel = [[FHHouseSaleInputModel alloc] init];
        
        [self configData];
        
        //埋点
//        [self addGoDetailTracer];
    }
    return self;
}

- (void)configData {
    self.inputModel.neighbourhoodId = self.viewController.neighbourhoodId;
    self.inputModel.neighbourhoodName = self.viewController.neighbourhoodName;
    self.view.neiborhoodItemView.contentText = self.viewController.neighbourhoodName;
}

- (void)viewWillAppear {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)viewWillDisappear {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -- textFieldDidChange

- (void)textFieldDidChange:(NSNotification *)notification {
    NSLog(@"11");
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

#pragma mark - FHHouseSaleInputViewDelegate

- (void)callBackDataInfo:(NSDictionary *)info {
    if (info && [info isKindOfClass:[NSDictionary class]]) {
//        self.infoModel.neighborhoodName = info[@"neighborhood_name"];
//        self.infoModel.neighborhoodId = info[@"neighborhood_id"];
//        self.view.neiborhoodItemView.contentLabel.text = self.infoModel.neighborhoodName;
//        [self checkEvaluateEnabled];
    }
}

- (void)goToNeighborhoodSearch {
    [self.view endEditing:YES];
    //埋点
//    [self addClickOptionsTracer:self.view.neiborhoodItemView.titleLabel.text];
    
    NSHashTable *delegate = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    [delegate addObject:self];
    NSMutableDictionary *dict = @{}.mutableCopy;
    dict[@"title"] = @"输入小区";
    dict[@"delegate"] = delegate;
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    
    NSURL* url = [NSURL URLWithString:@"sslocal://price_valuation_neighborhood_search"];
    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
}

@end
