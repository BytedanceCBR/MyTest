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
//    [self checkSubmitEnabled];
}

- (void)viewWillAppear {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)viewWillDisappear {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)checkSubmitEnabled {
    NSString *neiborhoodName = self.inputModel.neighbourhoodName;
    NSString *area = self.inputModel.area;
    NSString *floor = self.inputModel.floor;
    
    if(neiborhoodName && ![neiborhoodName isEqualToString:@""] && area && ![area isEqualToString:@""] && floor && ![floor isEqualToString:@""]){
        [self.view setSubmitBtnEnabled:YES];
    }else{
        [self.view setSubmitBtnEnabled:NO];
    }
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
        self.inputModel.neighbourhoodName = info[@"neighborhood_name"];
        self.inputModel.neighbourhoodId = info[@"neighborhood_id"];
        self.view.neiborhoodItemView.contentText = self.inputModel.neighbourhoodName;
        [self checkSubmitEnabled];
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
    dict[@"supportConfirmReturn"] = @(YES);
    dict[@"delegate"] = delegate;
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    
    NSURL* url = [NSURL URLWithString:@"sslocal://price_valuation_neighborhood_search"];
    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
}

- (void)houseSale {
    NSMutableDictionary *dict = @{}.mutableCopy;
    dict[@"title"] = @"发布成功";
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    NSURL* url = [NSURL URLWithString:@"sslocal://house_sale_result"];
    [[TTRoute sharedRoute] openURLByPresentViewController:url userInfo:userInfo];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self goBack];
    });
}

- (void)goBack {
    UIViewController *popVC = [self.viewController.navigationController popViewControllerAnimated:NO];
    
    if (nil == popVC) {
        [self.viewController dismissViewControllerAnimated:NO completion:^{
            
        }];
    }
}

@end
