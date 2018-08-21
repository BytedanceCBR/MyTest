//
//  WapData.m
//  Article
//
//  Created by Chen Hong on 15/3/3.
//
//

#import "WapData.h"
#import "ExploreWebCellManager.h"

@implementation WapData

@synthesize hasTemplateLoaded;
@synthesize shouldReloadCell;

+ (NSString *)dbName {
    return @"tt_news";
}

+ (NSArray *)persistentProperties {
    static NSArray *properties = nil;
    if (!properties) {
        properties = @[
                       @"uniqueID",
                       @"dataUrl",
                       @"baseUrl",
                       @"templateUrl",
                       @"templateMD5",
                       @"dataCallback",
                       @"refreshInterval",
                       @"templateContent",
                       @"dataContent",
                       @"lastUpdateTime",
                       ];
    }
    return properties;
}

+ (NSDictionary *)keyMapping {
    static NSDictionary *properties = nil;
    if (!properties) {
        properties = @{
                       @"baseUrl":@"base_url",
                       @"dataCallback":@"data_callback",
                       @"dataContent":@"data_content",
                       @"dataUrl":@"data_url",
                       @"lastUpdateTime":@"last_update_time",
                       @"refreshInterval":@"refresh_interval",
                       @"templateContent":@"template_content",
                       @"templateMD5":@"template_md5",
                       @"templateUrl":@"template_url",
                       };
    }
    return properties;
}

- (void)updateWithDictionary:(NSDictionary *)dictionary {
    NSString * oldTemplateURL = self.templateUrl;
    NSString * oldTemplateMD5 = self.templateMD5;
    [super updateWithDictionary:dictionary];
    if (oldTemplateMD5 && oldTemplateURL && !([oldTemplateURL isEqualToString:self.templateUrl] && [oldTemplateMD5 isEqualToString:self.templateMD5])) {
        self.templateContent = nil;
        self.dataContent = nil;
        self.hasTemplateLoaded = NO;
    }
    
}

- (void)updateWithTemplateContent:(NSString *)content templateMD5:(NSString *)md5 baseUrl:(NSString *)baseUrl {
//    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//    [dic setValue:content forKey:@"template_content"];
//    [dic setValue:md5 forKey:@"template_md5"];
//    [self updateWithDictionary:[dic copy]];
    
    self.templateContent = content;
    self.templateMD5 = md5;
    self.baseUrl = baseUrl;

    [self save];
//    if ([self hasChanges]) {
//        [[SSModelManager sharedManager] save:nil];
//    }
}

- (void)updateWithDataContentObj:(NSDictionary *)content {
    if (![content isKindOfClass:[NSDictionary class]]) {
        return;
    }
//    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//    [dic setValue:content forKey:@"data_content"];
//    [dic setValue:[NSDate date] forKey:@"last_update_time"];
//    [self updateWithDictionary:[dic copy]];
    
    self.dataContent = content;
    self.lastUpdateTime = [NSDate date];

    [self save];
//    if ([self hasChanges]) {
//        [[SSModelManager sharedManager] save:nil];
//    }
}

@end
