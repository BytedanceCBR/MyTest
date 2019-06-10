//
//  TTRealnameAuthModel.m
//  Article
//
//  Created by lizhuoli on 16/12/18.
//
//

#import "TTRealnameAuthModel.h"

@implementation TTRealnameAuthModel

+ (instancetype)sharedInstance
{
    static TTRealnameAuthModel *model;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        model = [TTRealnameAuthModel new];
    });
    
    return model;
}

+ (instancetype)modelWithState:(TTRealnameAuthState)state
{
    TTRealnameAuthModel *model = [TTRealnameAuthModel new];
    model.state = state;
    return model;
}

@end
