//
//  SSInHouseFeature.m
//  Article
//
//  Created by liufeng on 2017/8/14.
//
//

#import "SSInHouseFeature.h"

@implementation SSInHouseFeature

+ (SSInHouseFeature *)defaultFeatureWithDisable
{
    SSInHouseFeature *feature = [[SSInHouseFeature alloc] init];
    feature.login_phone_only = NO;
    feature.show_quick_feedback_gate = NO;
    return feature;
}

+ (SSInHouseFeature *)defaultLocalFeatureWithEnable
{
    SSInHouseFeature *feature = [[SSInHouseFeature alloc] init];
    feature.login_phone_only = YES;
    feature.show_quick_feedback_gate = YES;
    return feature;
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[SSInHouseFeature allocWithZone:zone] initWithDictionary:self.dictionaryRepresentation];
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
    [dictM setValue:@(_login_phone_only) forKey:@"login_phone_only"];
    [dictM setValue:@(_show_quick_feedback_gate) forKey:@"show_quick_feedback_gate"];
    return dictM;
}

- (SSInHouseFeature *)join:(SSInHouseFeature *)one
{
    self.login_phone_only = _login_phone_only && one.login_phone_only;
    self.show_quick_feedback_gate = _show_quick_feedback_gate && one.show_quick_feedback_gate;
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    if (self = [super init]) {
        _login_phone_only = [dict[@"login_phone_only"] boolValue];
        _show_quick_feedback_gate = [dict[@"show_quick_feedback_gate"] boolValue];
    }
    return self;
}

@end

