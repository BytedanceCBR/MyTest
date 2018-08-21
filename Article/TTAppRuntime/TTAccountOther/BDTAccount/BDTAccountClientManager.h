//
//  BDTAccountClientManager.h
//  Article
//
//  Created by zuopengliu on 14/9/2017.
//
//

#import <Foundation/Foundation.h>



typedef NS_ENUM(NSInteger, BDTABindingMobileFrom) {
    BDTABindingMobileFromLogin,
    BDTABindingMobileFromMine
};


@interface BDTAccountClientManager : NSObject

+ (instancetype)sharedAccountClient;


/**
 如果满足条件，显示绑定账号
 
 * 必须调用在主线程
 
 @param pageSource 显示绑定手机号的来源
 @param completion 绑定完成回调
 */
+ (void)presentBindingMobileVCFrom:(NSInteger)pageSource
                 bindingCompletion:(void (^)(BOOL finished /** 是否绑定成功 */))completion;

@end
