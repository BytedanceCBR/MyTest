//
//  TTAccountAuthResponse.m
//  TTAccountSDK
//
//  Created by liuzuopeng on 2/9/17.
//  Copyright © 2017 com.bytedance.news. All rights reserved.
//

#import "TTAccountAuthResponse.h"



@interface TTAccountAuthResponse ()

@property (nonatomic,   copy, readwrite) NSString *responseId;

@end

@implementation TTAccountAuthResponse

- (instancetype)init
{
    if ((self = [super init])) {
        _responseId = [[NSUUID UUID] UUIDString];
    }
    return self;
}

@end
