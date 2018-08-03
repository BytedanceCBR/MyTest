//
//  FRTipsEntity.m
//  Article
//
//  Created by ZhangLeonardo on 15/7/30.
//
//

#import "FRTipsEntity.h"
#import "FRApiModel.h"

@implementation FRTipsEntity


- (instancetype)initWithFromFRTipsStructModel:(FRTipsStructModel *)model
{
    if (!model) {
        return nil;
    }
    self = [super init];
    if (self) {
        self.display_duration = model.display_duration.longLongValue;
        self.display_info = model.display_info;
        self.click_url = model.click_url;
        
        if (_display_duration <= 0 || _display_duration >= 100) {
            _display_duration = 5;
        }
    }
    return self;
}

@end
