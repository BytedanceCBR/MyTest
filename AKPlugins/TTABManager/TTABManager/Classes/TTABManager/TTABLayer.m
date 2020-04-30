//
//  TTABLayer.m
//  ABTest
//
//  Created by ZhangLeonardo on 16/1/20.
//  Copyright © 2016年 ZhangLeonardo. All rights reserved.
//

#import "TTABLayer.h"
#import <objc/runtime.h>

const NSInteger kTTABTestMaxRegion = 999;

const NSString * kTTABDefaultGroupName = @"default";

#pragma mark -- TTABLayerExperiment

@interface TTABLayerExperiment()

@property(nonatomic, strong, readwrite)NSString * groupName;
@property(nonatomic, assign, readwrite)NSInteger minRegion;
@property(nonatomic, assign, readwrite)NSInteger maxRegion;
@property(nonatomic, strong, readwrite)NSDictionary * results;

@end

@implementation TTABLayerExperiment


- (id)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        self.groupName = [dict objectForKey:@"group_name"];
        self.minRegion = [[dict objectForKey:@"min_region"] longLongValue];
        self.maxRegion = [[dict objectForKey:@"max_region"] longLongValue];
        self.results = [dict objectForKey:@"results"];
        
        NSAssert([self _isValidate], @"ab.json experiment不合法");
    }
    return self;
}

/**
 *  验证有效性
 *
 *  @return YES：有效，NO：无效
 */
- (BOOL)_isValidate
{
    if (isEmptyString_forABManager(_groupName)) {
        return NO;
    }
    if (_minRegion >= _maxRegion) {
        return NO;
    }
    if (_minRegion < 0 || _minRegion > kTTABTestMaxRegion) {
        return NO;
    }
    if (_maxRegion > kTTABTestMaxRegion) {
        return NO;
    }
    if (![_results isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    return YES;
}

#ifdef DEBUG

- (NSString *)description
{
    return [self debugDescription];
}

#endif

- (NSString *)debugDescription
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    NSArray *exceptNames = @[@"minRegion", @"maxRegion"];
    uint count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    for (int i = 0; i < count; i++) {
        objc_property_t property = properties[i];
        NSString *name = @(property_getName(property));
        if (name && [exceptNames containsObject:name]) continue;
        
        id value = [self valueForKey:name] ? : @"nil";
        [dictionary setObject:value forKey:name];
    }
    if (properties) free(properties);
    
    [dictionary setValue:[NSString stringWithFormat:@"[%ld, %ld)", _minRegion, _maxRegion] forKey:@"region range"];
    [dictionary setValue:@([self _isValidate]) forKey:@"isValid"];
    return [NSString stringWithFormat:@"<%@: %p> = \n%@", NSStringFromClass(self.class), self, dictionary];
}

@end

#pragma mark -- TTABLayer

@interface TTABLayer()

@property(nonatomic, strong, readwrite)NSString * layerName;
@property(nonatomic, strong, readwrite)NSDictionary * filters;
@property(nonatomic, strong, readwrite)NSArray<TTABLayerExperiment *> * experiments;

@end

@implementation TTABLayer

- (id)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        self.layerName = [dict objectForKey:@"layer_name"];
        self.filters = [dict objectForKey:@"filters"];
        
        NSMutableArray<TTABLayerExperiment *> * expmts = (NSMutableArray<TTABLayerExperiment *> *)[NSMutableArray arrayWithCapacity:10];
        for (NSDictionary * tmpExpDict in [dict objectForKey:@"experiments"]) {
            TTABLayerExperiment * experment = [[TTABLayerExperiment alloc] initWithDict:tmpExpDict];
            if (experment) {
                [expmts addObject:experment];
            }
        }
        self.experiments = expmts;
        
        NSAssert([self _isValidate], @"ab.json experiment不合法");
        
    }
    return self;
}

/**
 *  验证有效性
 *
 *  @return YES：有效，NO：无效
 */
- (BOOL)_isValidate
{
    if (isEmptyString_forABManager(_layerName)) {
        return NO;
    }
    return YES;
}

- (TTABLayerExperiment *)experimentForRandomValue:(NSInteger)randomValue
{
    for (TTABLayerExperiment * experiment in _experiments) {
        if (randomValue >= experiment.minRegion &&
            randomValue <= experiment.maxRegion) {
            return experiment;
        }
    }
    return nil;
}

#ifdef DEBUG

- (NSString *)description
{
    return [self debugDescription];
}

#endif

- (NSString *)debugDescription
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    uint count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    for (int i = 0; i < count; i++) {
        objc_property_t property = properties[i];
        NSString *name = @(property_getName(property));
        id value = [self valueForKey:name] ? : @"nil";
        [dictionary setObject:value forKey:name];
    }
    if (properties) free(properties);
    
    [dictionary setValue:@([self _isValidate]) forKey:@"isValid"];
    return [NSString stringWithFormat:@"<%@: %p> = \n%@", NSStringFromClass(self.class), self, dictionary];
}

@end
