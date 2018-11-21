//
//  FHExploreHouseItemData.m
//  Article
//
//  Created by 张静 on 2018/11/20.
//

#import "FHExploreHouseItemData.h"
#import "FHSearchHouseModel.h"

@interface FHExploreHouseItemData ()

@property (nonatomic, copy , nullable) NSArray<FHSearchHouseDataItemsModel *> *itemList;

@end


@implementation FHExploreHouseItemData

- (void)updateWithDictionary:(NSDictionary *)dictionary {
    NSParameterAssert([dictionary isKindOfClass:[NSDictionary class]]);
    
    [super updateWithDictionary:dictionary];
    NSDictionary *raw_data = [dictionary tt_dictionaryValueForKey:@"raw_data"];
    if (raw_data != nil) {
        
        self.title = [raw_data tt_stringValueForKey:@"title"];
        self.items = [raw_data tt_arrayValueForKey:@"items"];
        self.loadmoreOpenUrl = [raw_data tt_stringValueForKey:@"loadmore_open_url"];
        self.imprType = [raw_data tt_stringValueForKey:@"impr_type"];
        self.loadmoreButton = [raw_data tt_stringValueForKey:@"loadmore_button"];
        self.houseType = [raw_data tt_stringValueForKey:@"house_type"];

        NSMutableArray *mutable = @[].mutableCopy;
        if (self.items.count > 0) {
            for (NSDictionary *item in self.items) {
                
                FHSearchHouseDataItemsModel *model =  [[FHSearchHouseDataItemsModel alloc]initWithDictionary:item error:nil];
                if (model != nil) {
                    [mutable addObject:model];
                }
            }
            self.itemList = mutable;
        }
        
    }
}

+ (NSArray *)persistentProperties {
    static NSArray *properties = nil;
    if (!properties) {
        NSMutableArray *props = [NSMutableArray arrayWithArray:[super persistentProperties]];
        properties = props;
        properties = [props arrayByAddingObjectsFromArray:@[
                                                            @"title",
                                                            @"items",
                                                            @"loadmoreOpenUrl",
                                                            @"imprType",
                                                            @"loadmoreButton",
                                                            @"houseType"]];
    };
    return properties;
}

//注.此处的映射，客户端以topic表示专题， 服务器端后面修改为subject。
+ (NSDictionary *)keyMapping {
    static NSDictionary *properties = nil;
    if (!properties) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:[super keyMapping]];
        [dict addEntriesFromDictionary:@{
                                         @"title":@"title",
                                         @"items":@"items",
                                         @"loadmoreOpenUrl":@"loadmore_open_url",
                                         @"imprType":@"impr_type",
                                         @"loadmoreButton":@"loadmore_button",
                                         @"houseType":@"house_type"
                                         }];
        properties = [dict copy];
    }
    return properties;
}


- (nullable NSArray<FHSearchHouseDataItemsModel *> *)houseItemList {
    
    return self.itemList;
}

@end
