//
//  HTSVideoPlayNetworkErrorModel.h
//  LiveStreaming
//
//  Created by Quan Quan on 16/2/26.
//  Copyright © 2016年 Bytedance. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface HTSVideoPlayNetworkErrorModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSNumber *code;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *prompts;
@property (nonatomic, strong) NSString *url;

@end
