//
//  TTProjectLogicManager.m
//  Article
//
//  Created by zhaoqin on 8/10/16.
//

#import "TTProjectLogicManager.h"

//配置文件类型
static  NSString *const kStrings = @"strings";

//配置文件名
static NSString *const kIPhoneProjectLogicSetting = @"IPhoneProjectLogicSetting";
static NSString *const kTargetLogicSetting = @"TargetLogicSetting";
static NSString *const kIPhoneLogicSetting = @"IPhoneLogicSetting";

@interface TTProjectLogicManager ()
@property (nonatomic, strong) NSMutableDictionary *logicDict;
@property (nonatomic, strong) NSMutableDictionary<NSString *, id<TTProjectLogicManagerResultMapper>> *mapperDict;
@end

@implementation TTProjectLogicManager

#pragma mark - initialization
+ (void)load {
    [TTProjectLogicManager sharedInstance_tt];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initLogicSettingDic];
    }
    return self;
}

//SSResourceManager中分别读取了strings类型和plist类型的配置文件，删除plist文件的读取
- (void)initLogicSettingDic {
    NSDictionary *iPhoneProjectLogiclogicDict = [TTProjectLogicManager dictionaryWithFilePathForResource:kIPhoneProjectLogicSetting type:kStrings];
    NSDictionary *targetLogiclogicDict = [TTProjectLogicManager dictionaryWithFilePathForResource:kTargetLogicSetting type:kStrings];
    NSDictionary *iPhoneLogiclogicDict = [TTProjectLogicManager dictionaryWithFilePathForResource:kIPhoneLogicSetting type:kStrings];
    self.logicDict = [[NSMutableDictionary alloc] init];
    self.mapperDict = [NSMutableDictionary<NSString *, id<TTProjectLogicManagerResultMapper>> dictionary];
    if (iPhoneProjectLogiclogicDict.count > 0) {
        [self.logicDict addEntriesFromDictionary:iPhoneProjectLogiclogicDict];
    }
    if (targetLogiclogicDict.count > 0) {
        [self.logicDict addEntriesFromDictionary:targetLogiclogicDict];
    }
    if (iPhoneLogiclogicDict.count > 0) {
        [self.logicDict addEntriesFromDictionary:iPhoneLogiclogicDict];
    }
    
}

#pragma mark - 获取配置数据（有默认值）
- (NSString *)logicStringForKey:(NSString *)key defaultValue:(NSString *)value {
    NSString *originalString = [self dictionary:_logicDict forKey:key defaultValue:value];
    NSString *mapResult;
    id<TTProjectLogicManagerResultMapper> mapper = self.mapperDict[key];
    if (mapper && [mapper respondsToSelector:@selector(mapString:)]) {
        mapResult = [mapper mapString:originalString];
        if (!mapResult) mapResult = [mapper mapString:key];
    }
    if (mapResult) {
        originalString = mapResult;
    }
    return originalString;
}

- (float)logicFloatForKey:(NSString *)key defaultValue:(float)value {
    return [[self dictionary:_logicDict forKey:key defaultValue:[NSNumber numberWithFloat:value]] floatValue];
}

- (int)logicIntForKey:(NSString *)key defaultValue:(int)value {
    return [[self dictionary:_logicDict forKey:key defaultValue:[NSNumber numberWithInt:value]] intValue];
}

- (NSDictionary *)logicDictionaryForKey:(NSString *)key defaultValue:(NSDictionary *)dict {
    return [self dictionary:_logicDict forKey:key defaultValue:dict];
}

- (NSArray *)logicArrayForKey:(NSString *)key defaultValue:(NSArray *)array {
    return [self dictionary:_logicDict forKey:key defaultValue:array];
}

- (BOOL)logicBoolForKey:(NSString *)key defaultValue:(BOOL)value {
    NSNumber *number = [NSNumber numberWithInt:value ? 1 : 0];
    return [[self dictionary:_logicDict forKey:key defaultValue:number] boolValue];
}

#pragma mark - 获取配置数据（无默认值）
- (NSString *)logicStringForKey:(NSString *)key {
    NSString *originalString = [self dictionary:_logicDict forKey:key];
    NSString *mapResult;
    id<TTProjectLogicManagerResultMapper> mapper = self.mapperDict[key];
    if (mapper && [mapper respondsToSelector:@selector(mapString:)]) {
        mapResult = [mapper mapString:originalString];
        if (!mapResult) mapResult = [mapper mapString:key];
    }
   
    if (mapResult) {
        originalString = mapResult;
    }
    return originalString;
}

- (float)logicFloatForKey:(NSString *)key {
    id result = [self dictionary:_logicDict forKey:key];
    if (!result) {
        return 0.0f;
    }
    return [result floatValue];
}

- (int)logicIntForKey:(NSString *)key {
    id result = [self dictionary:_logicDict forKey:key];
    if (!result) {
        return 0;
    }
    return [result intValue];
}

- (NSDictionary *)logicDictionaryForKey:(NSString *)key {
    return [self dictionary:_logicDict forKey:key];
}

- (NSArray *)logicArrayForKey:(NSString *)key {
    return [self dictionary:_logicDict forKey:key];
}

- (BOOL)logicBoolForKey:(NSString *)key {
    id result = [self dictionary:_logicDict forKey:key];
    if (!result) {
        return NO;
    }
    return [result boolValue];
}

#pragma mark - 工具方法
//SSResourceManager中只读取了TargetLogicSetting和IPhoneLogicSetting中的数据，其他配置文件在Resources.bundle中读取，但是Resoureces.bundle中没有对应的配置文件
+ (NSDictionary *)dictionaryWithFilePathForResource:(NSString *)name type:(NSString *)type {
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:type];
    NSDictionary * dict = nil;
    if (path) {
        dict = [NSDictionary dictionaryWithContentsOfFile:path];
    }
    return dict;
}

- (id)dictionary:(NSDictionary *)dict forKey:(NSString *)key defaultValue:(id)defaultValue {
    id result = [dict objectForKey:key];
    if (!result) {
        result = defaultValue;
    }
    return result;
}

- (id)dictionary:(NSDictionary *)dict forKey:(NSString *)key {
    id result = [dict objectForKey:key];
    if (!result) {
        NSLog(@"TTProjectLogicManager----no key named %@", key);
    }
    return result;
}

#pragma mark - TTResourceManagerResultMapper
- (void)registerMapper:(id<TTProjectLogicManagerResultMapper>)mapper {
    if (mapper) {
        self.mapperDict[mapper.key] = mapper;
    }
}

@end
