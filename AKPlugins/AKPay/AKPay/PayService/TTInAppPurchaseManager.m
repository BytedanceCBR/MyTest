//
//  TTInAppPurchase.m
//  Pods
//
//  Created by muhuai on 2017/10/9.
//

#import "TTInAppPurchaseManager.h"
#import <StoreKit/StoreKit.h>

NSString *const kTTIAPUpdatedTransactionsNotification = @"kTTIAPUpdatedTransactionsNotification";

@interface TTInAppPurchaseManager()<SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property (nonatomic, strong) NSMutableDictionary<NSString *, SKProduct *> *products;
@property (nonatomic, strong) NSMutableDictionary<NSString *, TTIAPStatusHandler> *callbacks;
@property (nonatomic, strong) NSMapTable<SKRequest *, TTIAPfetchProductCallback> *productRequestCallbacks;

@end

@implementation TTInAppPurchaseManager

+ (instancetype)sharedInstance {
    static TTInAppPurchaseManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[TTInAppPurchaseManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        _products = [[NSMutableDictionary alloc] init];
        _callbacks = [[NSMutableDictionary alloc] init];
        _productRequestCallbacks = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsStrongMemory capacity:5];
    }
    return self;
}

- (void)dealloc {
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

+ (BOOL)canMakePayments {
    return [SKPaymentQueue canMakePayments];
}

#pragma mark - fetch product
- (void)fetchProductWithIdentifiers:(NSArray<NSString *> *)identifiers completion:(TTIAPfetchProductCallback)completion {
    if (![identifiers isKindOfClass:[NSArray class]] || !identifiers.count) {
        if (completion) {
            completion(nil, [NSError errorWithDomain:@"" code:-1000 userInfo:@{NSLocalizedDescriptionKey: @"identifiers不合法"}]);
        }
        return;
    }
    
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:identifiers]];
    request.delegate = self;
    [self.productRequestCallbacks setObject:completion forKey:request];
    [request start];
}

#pragma mark -- SKProductsRequestDelegate
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    for (SKProduct *product in response.products) {
        [self.products setValue:product forKey:product.productIdentifier];
    }
    
    TTIAPfetchProductCallback callback = [self.productRequestCallbacks objectForKey:request];
    if (callback) {
        callback(response.products, nil);
    }
    
    [self.productRequestCallbacks removeObjectForKey:request];
}

- (void)requestDidFinish:(SKRequest *)request {
    [self.productRequestCallbacks removeObjectForKey:request];
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    TTIAPfetchProductCallback callback = [self.productRequestCallbacks objectForKey:request];
    if (callback) {
        callback(nil, error);
    }
    
    [self.productRequestCallbacks removeObjectForKey:request];
}


#pragma mark - pay
- (void)payWithIdentifier:(NSString *)identifier quantity:(NSInteger)quantity applicationUsername:(NSString *)applicationUsername statusHandler:(TTIAPStatusHandler)handler {
    if (![identifier isKindOfClass:[NSString class]] || !identifier.length) {
        if (handler) {
            handler(nil, [NSError errorWithDomain:@"" code:-1000 userInfo:@{NSLocalizedDescriptionKey: @"identifiers不合法"}]);
        }
        return;
    }
    
    if ([self.callbacks objectForKey:identifier]) {
        if (handler) {
            handler(nil, [NSError errorWithDomain:@"" code:-1001 userInfo:@{NSLocalizedDescriptionKey: @"有未完成的支付"}]);
        }
        return;
    }
    
    if (![self.class canMakePayments]) {
        if (handler) {
            handler(nil, [NSError errorWithDomain:@"" code:-1002 userInfo:@{NSLocalizedDescriptionKey: @"canMakePayments返回NO"}]);
        }
        return;
    }
    
    SKProduct *product = self.products[identifier];
    if (!product) {
        [self fetchProductWithIdentifiers:@[identifier] completion:^(NSArray<SKProduct *> *products, NSError *error) {
            if (error) {
                if (handler) {
                    handler(nil, error);
                }
                return;
            }
            [self payWithIdentifier:identifier quantity:quantity applicationUsername:applicationUsername statusHandler:handler];
        }];
        return;
    }
    
    SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];
    if (quantity > 1) {
        payment.quantity = quantity;
    }
    payment.applicationUsername = [self markApplicationUsername:applicationUsername];
    
    [self.callbacks setValue:handler forKey:identifier];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)clearTransaction:(SKPaymentTransaction *)transaction inQueue:(SKPaymentQueue *)queue {
    [self.callbacks removeObjectForKey:transaction.payment.productIdentifier];
    [queue finishTransaction:transaction];
}

#pragma mark -- SKPaymentTransactionObserver
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        if (![self shoudleHandleTransaction:transaction]) {
            return;
        }
        
        TTIAPStatusHandler handler = self.callbacks[transaction.payment.productIdentifier];
        if (handler) {
            handler(transaction, transaction.error);
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:kTTIAPUpdatedTransactionsNotification object:transaction];
        }
        
        
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
            case SKPaymentTransactionStateFailed:
            case SKPaymentTransactionStateRestored:
                [self clearTransaction:transaction inQueue:queue];
                break;
            default:
                break;
        }
    }
}

static NSString *markKey = @"__ttiap";

- (NSString *)markApplicationUsername:(NSString *)applicationUsername {
    return [applicationUsername stringByAppendingString:markKey]? :markKey;
}

- (NSString *)removeMarkApplicationUsername:(NSString *)applicationUsername {
    return [applicationUsername componentsSeparatedByString:markKey][0];
}

- (BOOL)shoudleHandleTransaction:(SKPaymentTransaction *)transaction {
    return [transaction.payment.applicationUsername containsString:markKey];
}
@end
