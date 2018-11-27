//
//  FHExploreHouseItemData.m
//  Article
//
//  Created by 张静 on 2018/11/20.
//

#import "FHExploreHouseItemData.h"
#import "FHSearchHouseModel.h"
#import "FHNewHouseItemModel.h"

@interface FHExploreHouseItemData ()

@property(nonatomic, strong) NSArray<FHNewHouseItemModel *> *itemList;
@property(nonatomic, strong) NSArray<FHSearchHouseDataItemsModel *> *secondItemList;

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
        self.logPb = [raw_data tt_dictionaryValueForKey:@"log_pb"];
        if (self.houseType.integerValue == FHHouseTypeNewHouse) {

            NSMutableArray *mutable = @[].mutableCopy;
            for (NSDictionary *dict in self.items) {
                
                FHNewHouseItemModel *model = [[FHNewHouseItemModel alloc]initWithDictionary:dict error:nil];
                if (model != nil) {
                    
                    [mutable addObject:model];
                }
            }
            self.itemList = mutable;
            
        }else if (self.houseType.integerValue == FHHouseTypeSecondHandHouse) {

            NSMutableArray *mutable = @[].mutableCopy;
            for (NSDictionary *dict in self.items) {
                
                FHSearchHouseDataItemsModel *model = [[FHSearchHouseDataItemsModel alloc]initWithDictionary:dict error:nil];
                if (model != nil) {
                    
                    [mutable addObject:model];
                }
            }
            self.secondItemList = mutable;
            
        }
    }
}

-(void)setItems:(NSArray<NSDictionary *> *)items {
    
    _items = items;
    if (self.houseType.integerValue == FHHouseTypeNewHouse) {

        NSMutableArray *mutable = @[].mutableCopy;
        for (NSDictionary *dict in self.items) {
            
            FHNewHouseItemModel *model = [[FHNewHouseItemModel alloc]initWithDictionary:dict error:nil];
            if (model != nil) {
                
                [mutable addObject:model];
            }
        }
        self.itemList = mutable;
        
    }else if (self.houseType.integerValue == FHHouseTypeSecondHandHouse) {

        NSMutableArray *mutable = @[].mutableCopy;
        for (NSDictionary *dict in self.items) {
            
            FHSearchHouseDataItemsModel *model = [[FHSearchHouseDataItemsModel alloc]initWithDictionary:dict error:nil];
            if (model != nil) {
                
                [mutable addObject:model];
            }
        }
        self.secondItemList = mutable;
        
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
                                                            @"logPb",
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
                                         @"logPb":@"log_pb",
                                         @"houseType":@"house_type"
                                         }];
        properties = [dict copy];
    }
    return properties;
}

-(NSArray<FHNewHouseItemModel *> *)houseList {
    
    if (!self.itemList) {
        if (self.houseType.integerValue == FHHouseTypeNewHouse) {

            NSMutableArray *mutable = @[].mutableCopy;
            for (NSDictionary *dict in self.items) {
                
                FHNewHouseItemModel *model = [[FHNewHouseItemModel alloc]initWithDictionary:dict error:nil];
                if (model != nil) {
                    
                    [mutable addObject:model];
                }
            }
            self.itemList = mutable;
            
        }
    }
    return self.itemList;
}

-(NSArray<FHSearchHouseDataItemsModel *> *)secondHouseList {
    
    if (!self.secondItemList) {
        if (self.houseType.integerValue == FHHouseTypeSecondHandHouse) {

            NSMutableArray *mutable = @[].mutableCopy;
            for (NSDictionary *dict in self.items) {
                
                FHSearchHouseDataItemsModel *model = [[FHSearchHouseDataItemsModel alloc]initWithDictionary:dict error:nil];
                if (model != nil) {
                    
                    [mutable addObject:model];
                }
            }
            self.secondItemList = mutable;
            
        }
    }
    return self.secondItemList;
}

@end
