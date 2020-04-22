//
//  FHLynxChannelConfig.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2020/4/22.
//

#import "FHLynxChannelConfig.h"
#import <ByteDanceKit/ByteDanceKit.h>

@implementation FHLynxTemplateConfig

+ (JSONKeyMapper *)keyMapper {
    return [JSONKeyMapper mapperForSnakeCase];
}

@end

@implementation FHLynxChannelIOSConfig

+ (JSONKeyMapper *)keyMapper {
    return [JSONKeyMapper mapperForSnakeCase];
}

- (NSArray<FHLynxTemplateConfig *> *)templateConfigList {
    NSMutableArray *configMutArray = [NSMutableArray array];
    for (NSDictionary *dict in self.templateList) {
        FHLynxTemplateConfig *config = [[FHLynxTemplateConfig alloc] initWithDictionary:dict error:nil ];
        if (config) {
            [configMutArray addObject:config];
        }
    }
    return configMutArray;
}

@end


@implementation FHLynxChannelConfig

+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
                                                                  @"version":@"version",
                                                                  @"iOS":@"iOS"
                                                                  }];
    
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

@end


@implementation FHLynxFontConfig

+ (JSONKeyMapper *)keyMapper {
    return [JSONKeyMapper mapperForSnakeCase];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

@end

@implementation FHLynxServerConfig

+ (JSONKeyMapper *)keyMapper {
    return [JSONKeyMapper mapperForSnakeCase];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

@end
