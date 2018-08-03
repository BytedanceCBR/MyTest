//
//  PhoneRegistrationManager.m
//  Article
//
//  Created by Dianwei on 14-7-4.
//
//

#import "PhoneRegistrationManager.h"
#import "SSHttpOperation.h"
#import "SSOperationManager.h"
#import "ArticleURLSetting.h"

@interface PhoneRegistrationManager()
@property(nonatomic, strong)SSHttpOperation *op;

@end

@implementation PhoneRegistrationManager

- (void)dealloc
{
    [_op cancelAndClearDelegate];
}

- (void)startSendCodeWithPhoneNumber:(NSString*)phoneNumber
                             captcha:(NSString*)captcha
                                type:(PhoneRegistrationScenarioType)type
                         finishBlock:(void(^)(NSError *error, NSNumber *retryTime, UIImage *captcha))finishBlock
{
    [_op cancelAndClearDelegate];
    NSMutableDictionary *getParam = [NSMutableDictionary dictionary];
    [getParam setValue:captcha forKey:@"captcha"];
    [getParam setValue:phoneNumber forKey:@"mobile"];
    [getParam setValue:@(type) forKey:@"type"];
    self.op = [SSHttpOperation httpOperationWithURLString:[NSURL URLWithString:[ArticleURLSetting PRSendCodeURLString]]
                                             getParameter:getParam
                                            postParameter:nil
                                              finishBlock:^(NSDictionary *result, NSError *error) {
                                                  NSNumber *retryTime = nil;
                                                  UIImage *captcha = nil;
                                                 if(!error)
                                                 {
                                                     NSDictionary *data = [[result objectForKey:@"result"] objectForKey:@"data"];
                                                     captcha = [self imageFromString:[data objectForKey:@"captcha"]];
                                                     retryTime = [data objectForKey:@"retry_time"];
                                                     
                                                 }
                                                  
                                                  if(finishBlock)
                                                  {
                                                      finishBlock(error, retryTime, captcha);
                                                  }
                                             }];
    
    [SSOperationManager addOperation:_op];
}

- (void)startRegisterWithPhoneNumber:(NSString*)phoneNumber
                                code:(NSString*)code
                             captcha:(NSString*)captcha
                         finishBlock:(void(^)(NSError *error, UIImage *captcha))finishBlock
{
    [_op cancelAndClearDelegate];
    NSMutableDictionary *getParams = [NSMutableDictionary dictionary];
    [getParams setValue:phoneNumber forKey:@"mobile"];
    [getParams setValue:code forKey:@"code"];
    [getParams setValue:captcha forKey:@"captcha"];
    
    self.op = [SSHttpOperation httpOperationWithURLString:[ArticleURLSetting PRRegisterURLString]
                                             getParameter:getParams
                                            postParameter:nil
                                              finishBlock:^(NSDictionary *result, NSError *error) {
                                                  UIImage *captcha = [self imageFromString:[[[result objectForKey:@"result"] objectForKey:@"data"] objectForKey:@"captcha"]];
                                                  
                                                  
                                                  if(finishBlock)
                                                  {
                                                      finishBlock(error, captcha);
                                                  }
                                              }];
    
    [SSOperationManager addOperation:_op];
}

- (void)startRefreshCaptchaWithFinishBlock:(void(^)(NSError *error, UIImage *captcha))finishBlock
{
    [_op cancelAndClearDelegate];
    
    NSMutableDictionary *getParams = [NSMutableDictionary dictionary];
    
    self.op = [SSHttpOperation httpOperationWithURLString:[ArticleURLSetting PRRefreshCaptchaURLString]
                                             getParameter:getParams
                                            postParameter:nil
                                              finishBlock:^(NSDictionary *result, NSError *error) {
                                                  UIImage *captcha = nil;
                                                  if([[result objectForKey:@"result"] objectForKey:@"data"])
                                                  {
                                                      captcha = [self imageFromString:[[[result objectForKey:@"result"] objectForKey:@"data"] objectForKey:@"captcha"]];
                                                  }
                                                  
                                                  if(finishBlock)
                                                  {
                                                      finishBlock(error, captcha);
                                                  }
                                              }];
    
    [SSOperationManager addOperation:_op];
}

- (UIImage*)imageFromString:(NSString*)string
{
    NSData *data = nil;
    if([SSCommon OSVersionNumber] >= 7.0)
    {
        data = [[NSData alloc] initWithBase64EncodedString:string options:NSDataBase64DecodingIgnoreUnknownCharacters];
    }
    else
    {
        data = [[NSData alloc] initWithBase64Encoding:string];
    }
    
    UIImage *result = [UIImage imageWithData:data];
    return result;
}



@end
