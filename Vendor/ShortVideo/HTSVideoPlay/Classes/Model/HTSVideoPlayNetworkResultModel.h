//
//  HTSVideoPlayNetworkResultModel.h
//  LiveStreaming
//
//  Created by Quan Quan on 16/2/26.
//  Copyright © 2016年 Bytedance. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface HTSVideoPlayNetworkResultModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSNumber *statusCode;

@end
