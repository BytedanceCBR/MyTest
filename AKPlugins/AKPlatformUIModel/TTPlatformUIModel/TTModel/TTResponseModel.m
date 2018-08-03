//
//  TTResponseModel.m
//  Forum
//
//  Created by Zhang Leonardo on 15-3-30.
//
//

#import "TTResponseModel.h"

@implementation TTResponseModel

- (instancetype) init {
    self = [super init];
    if (self) {
        self._ttCreateTimeStamp = @([[NSDate date] timeIntervalSince1970]);
    }
    
    return self;
}

@end
