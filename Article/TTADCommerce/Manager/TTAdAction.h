//
//  TTAdAction.h
//  Article
//
//  Created by yin on 2017/7/27.
//
//

#import <Foundation/Foundation.h>
#import "TTAdConstant.h"
#import "TTAdAppointAlertView.h"
#import "SSWebViewController.h"

@interface TTAdAction : NSObject

+ (BOOL)handleDownloadApp:(id<TTAd, TTAdAppAction>)model;

+ (BOOL)handleCallActionModel:(id<TTAdPhoneAction>)model;

+ (BOOL)handleFormActionModel:(id<TTAdFormAction>)model fromSource:(TTAdApointFromSource)fromSource completeBlock:(TTAdApointCompleteBlock)block;

+ (BOOL)handleDetailActionModel:(id<TTAdDetailAction, TTAd>)model sourceTag:(NSString *)tag;

+ (BOOL)handleDetailActionModel:(id<TTAdDetailAction, TTAd>)model sourceTag:(NSString *)tag completeBlock:(TTAppPageCompletionBlock)completeBlock;

+ (BOOL)handleWebActionModel:(id<TTAdDetailAction,TTAd>)model;

@end
