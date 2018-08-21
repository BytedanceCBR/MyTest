//
//  TTRPay.m
//  Article
//
//  Created by muhuai on 2017/5/18.
//
//

#import "TTRPay.h"
#import <TTBaseLib/NSStringAdditions.h>
#import <MBProgressHUD/MBProgressHUD.h> //为了手势拦截..必须使用三方库..对不住了..
#import <TTUIWidget/TTIndicatorView.h>
#import <TTRexxar/TTRJSBForwarding.h>
#import <AKPay/SSPayManager.h>
#import <TTTracker/TTTracker.h>
//#import <AKPay/TTInAppPurchaseManager.h>
#import <TTNetworkManager/TTNetworkManager.h>

@implementation TTRPay

+ (void)load {
    [[TTRJSBForwarding sharedInstance] registeJSBAlias:@"TTRPay.iap" for:@"iap"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [TTRPay sharedPlugin];
    });
}

+ (instancetype)sharedPlugin {
    static TTRPay *pay;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pay = [[TTRPay alloc] init];
    });
    return pay;
}

+ (TTRJSBInstanceType)instanceType {
    return TTRJSBInstanceTypeGlobal;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    self = [super init];
    if (self) {
//        [TTInAppPurchaseManager sharedInstance];
//        __weak __typeof(self)weakSelf = self;
//        [[NSNotificationCenter defaultCenter] addObserverForName:kTTIAPUpdatedTransactionsNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
//            __strong __typeof(weakSelf)strongSelf = weakSelf;
//            SKPaymentTransaction *transcation = [note.object isKindOfClass:[SKPaymentTransaction class]]? note.object: nil;
//            [strongSelf onUpdatedTransaction:transcation];
//        }];
    }
    
    return self;
}

//- (void)onUpdatedTransaction:(SKPaymentTransaction *)transcation {
//    if (transcation.transactionState != SKPaymentTransactionStatePurchased) {
//        return;
//    }
//
//    NSString *url = [self receiptURLWithapplicationUsername:transcation.payment.applicationUsername];
//    NSDictionary *param = [self receiptParamWithApplicationUsername:transcation.payment.applicationUsername];
//
//    NSMutableDictionary *mutableParam = [param mutableCopy];
//    [mutableParam setValue:[transcation.transactionReceipt base64EncodedStringWithOptions:0] forKey:@"receipt"];
//
//    if (!url.length) {
//        return;
//    }
//
//    [[TTNetworkManager shareInstance] requestForJSONWithURL:url params:[mutableParam copy] method:@"POST" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
//        NSDictionary *data = [jsonObj isKindOfClass:[NSDictionary class]]? jsonObj: nil;
//        NSInteger code = [data integerValueForKey:@"code" defaultValue:-1];
//
//        [TTTrackerWrapper eventV3:@"iap_receipt_recheck" params:({
//            NSMutableDictionary *mutableParam = [param mutableCopy];
//            [mutableParam setValue:@(code == 0? 1:0) forKey:@"success"];
//            [mutableParam copy];
//        })];
//    }];
//}

- (void)payWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller {
    NSDictionary * dictionary = [[param valueForKey:@"data"] valueForKey:@"data"];
    if ([[SSPayManager sharedPayManager] canPayForTrade:dictionary]) {
        [[SSPayManager sharedPayManager] payForTrade:dictionary finishHandler:^(NSDictionary *trade, NSInteger errorCode) {
            callback(TTRJSBMsgSuccess, @{@"code":@(errorCode)});
        }];
    }
}

//- (void)iapWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller {
//    NSString *identifier = [param tt_stringValueForKey:@"identifier"];
//    NSInteger quantity = [param tt_integerValueForKey:@"quantity"];
//    NSString *receiptURL = [param tt_stringValueForKey:@"check_receipt_url"];
//    NSDictionary *receiptParam = [param tt_dictionaryValueForKey:@"check_receipt_param"];
//
//    if (!identifier.length) {
//        TTR_CALLBACK_WITH_MSG(TTRJSBMsgParamError, @"identifier为空");
//        return;
//    }
//
//    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].delegate.window animated:YES];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].delegate.window animated:YES];
//    });
//
//    [TTTrackerWrapper eventV3:@"iap_start" params:param];
//    __weak typeof(webview) weakWebview = webview;
//    __weak __typeof(self)weakSelf = self;
//    [[TTInAppPurchaseManager sharedInstance] payWithIdentifier:identifier quantity:quantity applicationUsername:[self applicationUsernameWithReceiptURL:receiptURL param:receiptParam] statusHandler:^(SKPaymentTransaction *transaction, NSError *error) {
//        __strong __typeof(weakWebview)strongWebView = weakWebview;
//        __strong __typeof(weakSelf)strongSelf = weakSelf;
//        if (transaction.transactionState != SKPaymentTransactionStatePurchasing) {
//            [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].delegate.window animated:YES];
//        }
//
//        NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
//        [data setValue:@(transaction.transactionState) forKey:@"state"];
//        [data setValue:[transaction.transactionReceipt base64EncodedStringWithOptions:0] forKey:@"receipt"];
//        [data setValue:@(error.code) forKey:@"code"];
//        [data setValue:error.localizedDescription forKey:@"msg"];
//        [data setValue:identifier forKey:@"identifier"];
//        if (strongWebView) {
//            [strongWebView ttr_fireEvent:@"iap_state_change" data:data];
//            strongWebView = nil;
//        } else {
//            [strongSelf onUpdatedTransaction:transaction];
//        }
//
//        [TTTrackerWrapper eventV3:@"iap_state_change" params:({
//            NSMutableDictionary *copy = [data mutableCopy];
//            [copy removeObjectForKey:@"receipt"];
//            [copy copy];
//        })];
//    }];
//
//    TTR_CALLBACK_SUCCESS;
//}

static NSString *separatorKey = @"!@#";
//因为只有一个applicationUsername可以使用...所以得手动把所有信息拼到一起
- (NSString *)applicationUsernameWithReceiptURL:(NSString *)url param:(NSDictionary *)param {
    NSMutableString *result = [@"ttpay" mutableCopy];
    [result appendString:separatorKey];
    [result appendString:url];
    [result appendString:separatorKey];
    [result appendString:[param JSONRepresentation]];
    
    return [result copy];
}

//- (NSString *)receiptURLWithapplicationUsername:(NSString *)applicationUsername {
//    applicationUsername = [[TTInAppPurchaseManager sharedInstance] removeMarkApplicationUsername:applicationUsername];
//    NSArray<NSString *> *split = [applicationUsername componentsSeparatedByString:separatorKey];
//    if (split.count != 3) {
//        return nil;
//    }
//
//
//    return split[1];
//}

//- (NSDictionary *)receiptParamWithApplicationUsername:(NSString *)applicationUsername {
//    applicationUsername = [[TTInAppPurchaseManager sharedInstance] removeMarkApplicationUsername:applicationUsername];
//    NSArray<NSString *> *split = [applicationUsername componentsSeparatedByString:separatorKey];
//    if (split.count != 3) {
//        return nil;
//    }
//    
//    NSDictionary *json = [split[2] JSONValue];
//
//    return [json isKindOfClass:[NSDictionary class]]? json: nil;
//}
@end
