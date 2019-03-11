//
//  TTAdCallManager.h
//  Article
//
//  Created by yin on 2016/11/28.
//
//

#import <Foundation/Foundation.h>
#import "TTAdConstant.h"

@class TTAdCallListenModel;

@interface TTAdCallManager : NSObject

+ (instancetype)sharedManager;

- (void)callAdModel:(TTAdCallListenModel*)model;

//用于落地页电话监听
- (void)callAdModel:(TTAdCallListenModel*)model block:(TTAdCallListenBlock)block;

- (void)callAdDict:(NSDictionary *)dict;

+ (void)callWithNumber:(NSString*)phoneNumer;

+ (BOOL)callWithModel:(id<TTAdPhoneAction>)model;

@end


@interface TTAdCallModel :NSObject<TTAdPhoneAction>

@property (nonatomic, copy) NSString *phoneNumber;

- (instancetype)initWithPhoneNumber:(NSString *)phoneNumber;

@end

@interface TTAdCallListenModel : NSObject

@property (nonatomic, strong) NSString* ad_id;
@property (nonatomic, strong) NSString* log_extra;
@property (nonatomic, strong) NSString* position; //feed流、detail页
@property (nonatomic, strong) NSDate* dailTime;  //播出时间
@property (nonatomic, strong) NSNumber* dailActionType;

//默认NO,广告落地页web唤起电话 YES:web调起  NO:native直接拨打
@property (nonatomic, assign) BOOL isWebCall;
@property (nonatomic, assign) BOOL toListen;

@end
