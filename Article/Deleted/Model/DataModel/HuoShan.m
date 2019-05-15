//
//  HuoShan.m
//  
//
//  Created by Chen Hong on 16/6/6.
//
//

#import "HuoShan.h"
#import "TTImageInfosModel.h"

@implementation HuoShan

//+ (NSEntityDescription*)entityDescriptionInManager:(SSModelManager *)manager
//{
//    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:manager];
//    return entityDescription;
//}
//
//+ (NSString*)entityName
//{
//    return @"HuoShan";
//}
//
//+ (NSArray*)primaryKeys
//{
//    return @[@"uniqueID"];
//}

+ (NSString *)dbName {
    return @"tt_news";
}

+ (NSArray *)persistentProperties {
    static NSArray *properties = nil;
    if (!properties) {
        properties = @[
                       @"uniqueID",
                       @"liveId",
                       @"title",
                       @"viewCount",
                       @"coverImageInfo",
                       @"middleImageInfo",
                       @"userInfo",
                       @"mediaInfo",
                       @"shareInfo",
                       @"filterWords",
                       @"label",
                       @"labelStyle",
                       @"cellFlag",
                       @"actionList",
                       @"nhdImageInfo",
                       ];
    }
    return properties;
}

+ (NSDictionary *)keyMapping {
    static NSDictionary *properties = nil;
    if (!properties) {
        properties = @{
                       @"cellFlag":@"cell_flag",// cell控制字段
                       @"labelStyle":@"label_style",// 标签样式
                       @"liveId":@"live_id",// 直播id
                       @"viewCount":@"view_count",// 围观人数
                       };
    }
    return properties;
}

- (void)updateWithDictionary:(NSDictionary *)dataDict {
    [super updateWithDictionary:dataDict];

    // 封面图 1：1
    if ([dataDict objectForKey:@"cover_image_info"]) {
        self.coverImageInfo = [dataDict tt_dictionaryValueForKey:@"cover_image_info"];
    }
    // 封面图 16：9
    if ([dataDict objectForKey:@"nhd_image_info"]) {
        self.nhdImageInfo = [dataDict tt_dictionaryValueForKey:@"nhd_image_info"];
    }
    
    // 右图
    if ([dataDict objectForKey:@"middle_image_info"]) {
        self.middleImageInfo = [dataDict tt_dictionaryValueForKey:@"middle_image_info"];
    }
    
    // 主播信息
    if ([dataDict objectForKey:@"user_info"]) {
        self.userInfo = [dataDict tt_dictionaryValueForKey:@"user_info"];
    }
    
    // 分享信息
    if ([dataDict objectForKey:@"share_info"]) {
        self.shareInfo = [dataDict tt_dictionaryValueForKey:@"share_info"];
    }
    // PGC信息（火山直播头条号）
    if ([dataDict objectForKey:@"media_info"]) {
        self.mediaInfo = [dataDict tt_dictionaryValueForKey:@"media_info"];
    }
    
    
    // 下拉更多列表
    if ([dataDict objectForKey:@"action_list"]) {
        self.actionList = [dataDict tt_arrayValueForKey:@"action_list"];
    }
    
    // 不喜欢的理由
    if ([dataDict objectForKey:@"filter_words"]) {
        self.filterWords = [dataDict tt_arrayValueForKey:@"filter_words"];
    }
}

- (nullable TTImageInfosModel *)coverImageModel {
    if (![self.coverImageInfo isKindOfClass:[NSDictionary class]] || [self.coverImageInfo count] == 0) {
        return nil;
    }
    TTImageInfosModel *model = [[TTImageInfosModel alloc] initWithDictionary:self.coverImageInfo];
    model.imageType = TTImageTypeLarge;
    return model;
}

- (nullable TTImageInfosModel *)nhdImageModel {
    if (![self.nhdImageInfo isKindOfClass:[NSDictionary class]] || [self.nhdImageInfo count] == 0) {
        return nil;
    }
    TTImageInfosModel *model = [[TTImageInfosModel alloc] initWithDictionary:self.nhdImageInfo];
    model.imageType = TTImageTypeLarge;
    return model;
}

- (nullable TTImageInfosModel *)middleImageModel {
    if (![self.middleImageInfo isKindOfClass:[NSDictionary class]] || [self.middleImageInfo count] == 0) {
        return nil;
    }
    TTImageInfosModel *model = [[TTImageInfosModel alloc] initWithDictionary:self.middleImageInfo];
    model.imageType = TTImageTypeMiddle;
    return model;
}


@end
