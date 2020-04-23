//
//  TTABManager.m
//  ABTest
//
//  Created by ZhangLeonardo on 16/1/19.
//  Copyright © 2016年 ZhangLeonardo. All rights reserved.
//

#import "TTABManager.h"
#import "TTABLayer.h"
#import "TTABStorageManager.h"
#import "TTABManagerUtil.h"

#define kTTABGroupSeparator @","
#define kTTABFeatureSeparator @","

#define kFilterKeysDefaultKey @"__default_key"
#define kExplermentDefaultGroupNameKey @"__default_key"


@interface TTABManager()
{
    /**
     *  出现了异常， 当出现异常的时候， abFeature, abGroup都返回nil, 分组如果没有进行也不再进行
     */
    BOOL _hasException;
}

@property (atomic, copy) NSString *abGroupStr;
@property (atomic, copy) NSString *abFeatureStr;
@property (atomic, copy) NSString *abVersionStr;
@property (nonatomic, strong) NSMutableArray<TTABLayer *> *layers;
@property (nonatomic, strong) TTABStorageManager *featureKeyManager;
@property (nonatomic, strong) NSDictionary *filterKeys;


@end

@implementation TTABManager

- (id)init
{
    self = [super init];
    if (self) {
        self.featureKeyManager = [[TTABStorageManager alloc] init];
    }
    return self;
}

- (void)didFinishLaunch
{
    //ab version, 先读取ab version以防客户端ab.json出错
    self.abVersionStr = [TTABStorageManager ABVersion];

    if (_hasException) {
        return;
    }
    NSDictionary * ABJSON = [TTABManagerUtil readABJSON];
    
    if ((![ABJSON isKindOfClass:[NSDictionary class]] ||
         [ABJSON count] == 0)) {
        NSLog(@"没有找到ab.json文件或读取异常！！！！！！");
        _hasException = YES;
        return;
    }
    
    //ab feature
    self.filterKeys = [ABJSON objectForKey:@"filter_keys"];
    //先写入filter keys 的默认值
    [self _synchronizeFilterKeysDefaultKeyIfNeed];
    

    //ab groups
    //获取或者分配ab_groups
    BOOL currentVersionAllocationed = [TTABStorageManager isABGroupAllocationed];
    if (currentVersionAllocationed) {
        self.abGroupStr = [TTABStorageManager currentSavedABGroups];
    }
    else {
        [self _launchDistributionForABGroup:ABJSON];
    }

    // ab feature
    self.abFeatureStr = [self calculateABFeatureStr];
    
}

- (NSString *)ABGroup
{
    if (_hasException) {
        return nil;
    }
    if (isEmptyString_forABManager(self.abFeatureStr)) {
        return nil;
    }
    return self.abGroupStr;
}

- (NSString *)ABFeature
{
    if (_hasException) {
        return nil;
    }

    if (_featureKeyManager.dirtyData) {
        _featureKeyManager.dirtyData = NO;
        self.abFeatureStr = [self calculateABFeatureStr];
    }
    return self.abFeatureStr;
}

- (NSString *)ABVersion
{
    return self.abVersionStr;
}

- (void)saveABVersion:(NSString *)abVersion
{
    if (isEmptyString_forABManager(abVersion)) {
        return;
    }
    self.abVersionStr = abVersion;
    [TTABStorageManager saveABVersion:self.abVersionStr];
}

- (NSString *)valueForFeatureKey:(NSString *)featureKey
{
    return [_featureKeyManager valueForFeatureKey:featureKey];
}

- (void)saveServerSettings:(NSDictionary *)dict
{
    if (![dict isKindOfClass:[NSDictionary class]] || [dict count] == 0) {
        return;
    }

    NSMutableDictionary * changeDict = [NSMutableDictionary dictionaryWithCapacity:10];
    
    for (NSString * key in [dict allKeys]) {
        if (isEmptyString_forABManager(key)) {
            continue;
        }
        NSString * value = [dict objectForKey:key];
        if (isEmptyString_forABManager(value)) {
            continue;
        }
        if ([[_filterKeys allKeys] containsObject:key]) {
            [changeDict setValue:value forKey:key];
        }
    }
    
    [_featureKeyManager batchSetKeyValues:changeDict];
}

#pragma mark -- ABGroups logic

- (void)_launchDistributionForABGroup:(NSDictionary *)ABJSON
{
    [self _loadLayers:ABJSON];
    [self _generateLayerRandomNumberIfNeed];
    self.abGroupStr = [self _calculateABGroups];
    [TTABStorageManager saveCurrentVersionABGroups:self.abGroupStr];
}

- (void)_loadLayers:(NSDictionary *)ABJSON
{
    if ([_layers count] > 0) {
        return;
    }
    NSArray * ary = [ABJSON objectForKey:@"traffic_map"];
    self.layers = (NSMutableArray<TTABLayer *> *)[NSMutableArray arrayWithCapacity:10];
    for (NSDictionary * layerDict in ary) {
        TTABLayer * layer = [[TTABLayer alloc] initWithDict:layerDict];
        [_layers addObject:layer];
    }
}

/**
 *  为每个没有分配随机数的layer分配一个随机数
 */
- (void)_generateLayerRandomNumberIfNeed
{
    NSMutableDictionary * randomNumbers =
    [NSMutableDictionary dictionaryWithDictionary:[TTABStorageManager randomNumber]];
    for (TTABLayer * layer in _layers) {
        if (![[randomNumbers allKeys] containsObject:layer.layerName]) {
            NSInteger randomNumber = [TTABManagerUtil genARandomNumber];
            [randomNumbers setValue:@(randomNumber) forKey:layer.layerName];
        }
    }
    [TTABStorageManager saveRandomNumberDicts:randomNumbers];
}

- (NSString *)_calculateABGroups {
    
    NSMutableString * abGroups = [NSMutableString stringWithCapacity:10];
    
    NSMutableDictionary * randomValues = [NSMutableDictionary dictionaryWithDictionary:[TTABStorageManager randomNumber]];
    
    NSMutableDictionary * executedGroupNames = [NSMutableDictionary dictionaryWithDictionary:[TTABStorageManager executedExperimentGroupNames]];
    
    for (TTABLayer * layer in _layers) {
        
        BOOL passVerify = [self _isPassLayerFiltersVerify:layer];
        if (!passVerify) {//未通过验证，该层不参与试验
            continue;
        }
        
        NSInteger rValue = [[randomValues objectForKey:layer.layerName] integerValue];
        TTABLayerExperiment * experiment = [layer experimentForRandomValue:rValue];
        [self _executeExperiment:experiment];
        NSString * groupName = experiment.groupName;
        if (!isEmptyString_forABManager(groupName) &&
            ![groupName isEqualToString:kExplermentDefaultGroupNameKey]) {
            if ([abGroups length] > 0) {
                [abGroups appendString:kTTABGroupSeparator];
            }
            [abGroups appendString:groupName];
            //记录layer对应的执行了的分组, 默认组不记录
            [executedGroupNames setValue:groupName forKey:layer.layerName];
        }
    }
    [TTABStorageManager saveExecutedExperimentGroupNames:executedGroupNames];
    return [abGroups copy];
}

/**
 *  把实验的结果设置进去
 *
 *  @param experiment 设置实验结果
 */
- (void)_executeExperiment:(TTABLayerExperiment *)experiment
{
    [_featureKeyManager batchSetKeyValues:experiment.results];
}

#pragma mark -- filter keys logic

/**
 *  判断是否通过了layer的filter验证
 *
 *  @param layer 待判断的layer
 *
 *  @return YES:通过,NO:未通过
 */
- (BOOL)_isPassLayerFiltersVerify:(TTABLayer *)layer
{
    BOOL isPass = [self _verifyChannelFilters:layer];
    if (!isPass) {
        return NO;
    }
    isPass = [self _verifyFirstInstallVersion:layer];
    if (!isPass) {
        return NO;
    }
    isPass = [self _verifyNormalFilterKeys:layer];
    return isPass;
}

#define kTTABManagerLayerFilterKeyChannelKey @"channel"
#define kTTABManagerLayerFilterKeyChannelNegationKey @"!"
#define kTTABManagerLayerFilterKeyChannelSeparatorKey @","
/**
 *  验证channel的条件是否通过
 *
 *  @param layer 待验证的layer
 *
 *  @return YES：通过验证， NO：未通过验证
 */
- (BOOL)_verifyChannelFilters:(TTABLayer *)layer
{
    if ([[layer.filters allKeys] containsObject:kTTABManagerLayerFilterKeyChannelKey]) {
        
        NSString * filterChannel = [layer.filters objectForKey:kTTABManagerLayerFilterKeyChannelKey];
        
        if (isEmptyString_forABManager(filterChannel)) {
            return YES;
        }
        NSString * appChannel = [TTABManagerUtil channelName];
        if (isEmptyString_forABManager(appChannel)) {
            NSLog(@"warning 没有读取到当前app 的channel ！！！");
            return YES;
        }
        
        BOOL isNegation = [filterChannel hasPrefix:kTTABManagerLayerFilterKeyChannelNegationKey];
        
        if (isNegation) { //!开头
            NSString * noNegationChannelStr = [filterChannel substringFromIndex:[kTTABManagerLayerFilterKeyChannelNegationKey length]];
            if (isEmptyString_forABManager(noNegationChannelStr)) {
                NSLog(@"ab.json channel 部分出现异常!!!");
                return YES;
            }
            NSArray<NSString *> * channelStrs = [noNegationChannelStr componentsSeparatedByString:kTTABManagerLayerFilterKeyChannelSeparatorKey];
            BOOL contain = [channelStrs containsObject:appChannel];
            return !contain;
        }
        else {//看当前app 的渠道是否在自定的渠道中
            NSArray<NSString *> * channelStrs = [filterChannel componentsSeparatedByString:kTTABManagerLayerFilterKeyChannelSeparatorKey];
            BOOL contain = [channelStrs containsObject:appChannel];
            return contain;
        }
    }
    else {
        return YES;
    }
}

#define kTTABManagerLayerFilterKeyFirstInstallVersionKey @"first_install_version"

#define kTTABManagerLayerFilterKeyFirstInstallVersionLessKey @"<"
#define kTTABManagerLayerFilterKeyFirstInstallVersionGreateOrEqualKey @">="

- (BOOL)_verifyFirstInstallVersion:(TTABLayer *)layer
{
    NSString * versionFilter = [layer.filters objectForKey:kTTABManagerLayerFilterKeyFirstInstallVersionKey];
    if (isEmptyString_forABManager(versionFilter)) {
        return YES;
    }
    NSString * appFirstInstallVersion = [TTABStorageManager firstInstallVersionStr];
    if ([versionFilter hasPrefix:kTTABManagerLayerFilterKeyFirstInstallVersionGreateOrEqualKey]) {//x.x及之后的新用户(>=)
        
        NSString * ver = [versionFilter substringFromIndex:[kTTABManagerLayerFilterKeyFirstInstallVersionGreateOrEqualKey length]];
        if (isEmptyString_forABManager(ver)) {
            NSLog(@"ab.json version 判断 出现异常");
            return YES;
        }
        
        TTABVersionCompareType compareType = [TTABManagerUtil compareVersion:appFirstInstallVersion toVersion:ver];
        if (compareType == TTABVersionCompareTypeEqualTo ||
            compareType == TTABVersionCompareTypeGreateThan) {
            return YES;
        }
        return NO;
    }
    else if ([versionFilter hasPrefix:kTTABManagerLayerFilterKeyFirstInstallVersionLessKey]){
        NSString * ver = [versionFilter substringFromIndex:[kTTABManagerLayerFilterKeyFirstInstallVersionLessKey length]];
        if (isEmptyString_forABManager(ver)) {
            NSLog(@"ab.json version 判断 出现异常");
            return YES;
        }
        TTABVersionCompareType compareType = [TTABManagerUtil compareVersion:appFirstInstallVersion toVersion:ver];
        if (compareType == TTABVersionCompareTypeLessThan) {
            return YES;
        }
        return NO;
    }
    NSLog(@"ab.json version 判断 出现异常");
    return YES;
}

- (BOOL)_verifyNormalFilterKeys:(TTABLayer *)layer
{
    __block BOOL result = YES;
    [layer.filters enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        BOOL isSpecialFilterKeys =
        [key isEqualToString:kTTABManagerLayerFilterKeyChannelKey] ||
        [key isEqualToString:kTTABManagerLayerFilterKeyFirstInstallVersionKey];
        if (!isSpecialFilterKeys) {
            NSString * value = [_featureKeyManager valueForFeatureKey:key];
            NSString * layerFilterValue = [layer.filters objectForKey:key];
            if (!isEmptyString_forABManager(layerFilterValue)) {
                if (![value isEqualToString:layerFilterValue]) {
                    result = NO;
                    *stop = YES;
                    return;
                }
            }
        }
    }];
    return result;
}


#pragma mark -- ABFeatures logic

/**
 *  同步没有值的filter key。
 */
- (void)_synchronizeFilterKeysDefaultKeyIfNeed
{
    NSArray * keys = [_filterKeys allKeys];
    
    NSMutableDictionary * result = [NSMutableDictionary dictionaryWithCapacity:10];
    
    for (NSString * key in keys) {
        NSString * value = [_featureKeyManager valueForFeatureKey:key];
        //如果没有默认值
        if (isEmptyString_forABManager(value)) {
            //将ab json中的默认值写入存储区
            NSString * tmpValue = [[_filterKeys objectForKey:key] objectForKey:kFilterKeysDefaultKey];
            [result setValue:tmpValue forKey:key];
        }
    }
    [_featureKeyManager batchSetKeyValues:result];
}

/**
 *  根据存储的filter key 的value ，对应到fileterkey中默认的值，动态计算出ab feature
 *
 *  @return ab feature
 */
- (NSString *)calculateABFeatureStr{
    NSMutableString * result = [NSMutableString stringWithCapacity:10];
    
    NSArray * keys = [_filterKeys allKeys];
    for (NSString * key in keys) {
        NSString * value = [_featureKeyManager valueForFeatureKey:key];
        NSString * featureKey = [[_filterKeys objectForKey:key] objectForKey:value];
        if (!isEmptyString_forABManager(featureKey)) {
            if (!isEmptyString_forABManager(result)) {
                [result appendString:kTTABFeatureSeparator];
            }
            [result appendString:featureKey];
        }
    }
    return result;
}

@end
