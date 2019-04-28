//
//  TTBridgeCommand.h
//  TTBridgeUnify
//
//  Modified from TTRexxar of muhuai.
//  Created by 李琢鹏 on 2018/10/30.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    TTBridgeTypeCall = 0,
    TTBridgeTypeOn,
} TTBridgeType;

@interface TTBridgeCommand : NSObject

@property (nonatomic, assign) TTBridgeType bridgeType;

@property(nonatomic, copy) NSString *messageType;

@property(nonatomic, copy) NSString *eventID;

@property(nonatomic, copy) NSString *callbackID;

@property(nonatomic, copy) NSDictionary *params;


/**
 前端传过来的方法名, 格式："命名空间.方法名"
 */
@property(nonatomic, copy) NSString *fullName;

/**
 经过别名映射后, 该property为 映射前的fullName
 */
@property(nonatomic, copy) NSString *origName;

/**
 plugin的 类名
 */
@property(nonatomic, copy) NSString *className;

/**
 plugin的 方法名
 */
@property(nonatomic, copy) NSString *methodName;

/**
 没卵用
 */
@property(nonatomic, copy) NSString *JSSDKVersion;

/**
 收到请求的时间
 */
@property (nonatomic, copy) NSString *startTime;

/**
 回调前端的时间
 */
@property (nonatomic, copy) NSString *endTime;

- (instancetype)initWithDictonary:(NSDictionary *)dic;

- (NSString *)toJSONString;
@end
