//
//  FHHouseFindSelectModel.m
//  FHHouseFind
//
//  Created by 春晖 on 2019/2/13.
//

#import "FHHouseFindSelectModel.h"
#import "NSDictionary+BTDAdditions.h"
#import "NSArray+BTDAdditions.h"

@implementation FHHouseFindSelectItemModel

-(instancetype)init
{
    self = [super init];
    if (self) {
        _selectIndexes = [NSMutableArray new];
    }
    return self;
}

-(NSString *)selectQuery
{
    NSMutableString *query = [[NSMutableString alloc] init];
    if (self.tabId == FHSearchTabIdTypePrice) {
 
        if (!self.rate) {
            return nil;
        }
        
        NSInteger r = self.rate.integerValue;
        if (self.lowerPrice && self.higherPrice) {            
            NSInteger lowPrice = self.lowerPrice.integerValue;
            NSInteger highPrice = self.higherPrice.integerValue;
            if (lowPrice > highPrice) {
                NSInteger temp = lowPrice;
                lowPrice = highPrice;
                highPrice = temp;
            }
            if (highPrice == 0 && self.fromType == FHHouseFindPriceFromTypeHelp) {
                [query appendFormat:@"%@[]=[%ld]",self.configOption.type?:@"price",lowPrice*r];
            }else {
                [query appendFormat:@"%@[]=[%ld,%ld]",self.configOption.type?:@"price",lowPrice*r,highPrice*r];
            }
            
        }else if (self.lowerPrice){
            NSInteger lowPrice = self.lowerPrice.integerValue;
            [query appendFormat:@"%@[]=[%ld]",self.configOption.type?:@"price",lowPrice*r];
            
        }else if (self.higherPrice){
            NSInteger highPrice = self.higherPrice.integerValue;
            if (highPrice > 0) {
                [query appendFormat:@"%@[]=[0,%ld]",self.configOption.type?:@"price",highPrice*r];
            }else {
                [query appendFormat:@"%@[]=[%ld]",self.configOption.type?:@"price",0];
            }
        }else{
            if (self.fromType == FHHouseFindPriceFromTypeHelp) {
                for (NSNumber *index in self.selectIndexes) {
                    if (self.configOption.options.count > index.integerValue) {
                        FHSearchFilterConfigOption *op = self.configOption.options[index.integerValue];
                        if (query.length > 0) {
                            [query appendString:@"&"];
                        }
                        [query appendFormat:@"%@[]=%@",op.type,op.value];
                    }
                }
//                [query appendFormat:@"%@[]=[]",self.configOption.type?:@"price"];
            }
        }
        
        /*
         let rate: Int = self.priceNodeItem?.rate ?? 1
         let e = (Int(priceInputCell.leftPriceInput.text ?? "0"), Int(priceInputCell.rightPriceInput.text ?? "0"))
         switch e {
         case let (left, nil) where left != nil:
         return "\(priceItem.type ?? "price")[]=[\(left! * rate)]"
         case let (nil, right) where right != nil:
         return "\(priceItem.type ?? "price")[]=[0,\(right! * rate)]"
         case (nil, nil):
         return nil
         case let (left, right) where left! > right!:
         return "\(priceItem.type ?? "price")[]=[\(right! * rate),\(left! * rate)]"
         case let (left, right) where left! <= right!:
         return "\(priceItem.type ?? "price")[]=[\(left! * rate),\(right! * rate)]"
         
         default:
         print("default")
         }
         return "\(priceItem.type ?? "price")[]=[]"
         */
        
    }else{
        
        if (!_configOption) {
            return nil;
        }
        
        for (NSNumber *index in self.selectIndexes) {
            if (self.configOption.options.count > index.integerValue) {
                FHSearchFilterConfigOption *op = self.configOption.options[index.integerValue];
                if (query.length > 0) {
                    [query appendString:@"&"];
                }
                [query appendFormat:@"%@[]=%@",op.type,op.value];
            }
        }
    }
    
    return [query copy];
}

//该方法用于帮我找房区域选择
- (NSString *)selectQueryForFindingHouse
{
    NSMutableString *query = [[NSMutableString alloc] init];
    if (self.tabId == FHSearchTabIdTypePrice) {
 
        if (!self.rate) {
            return nil;
        }
        
        NSInteger r = self.rate.integerValue;
        if (self.lowerPrice && self.higherPrice) {
            NSInteger lowPrice = self.lowerPrice.integerValue;
            NSInteger highPrice = self.higherPrice.integerValue;
            if (lowPrice > highPrice) {
                NSInteger temp = lowPrice;
                lowPrice = highPrice;
                highPrice = temp;
            }
            if (highPrice == 0 && self.fromType == FHHouseFindPriceFromTypeHelp) {
                [query appendFormat:@"%@[]=[%ld]",self.configOption.type?:@"price",lowPrice*r];
            }else {
                [query appendFormat:@"%@[]=[%ld,%ld]",self.configOption.type?:@"price",lowPrice*r,highPrice*r];
            }
            
        }else if (self.lowerPrice){
            NSInteger lowPrice = self.lowerPrice.integerValue;
            [query appendFormat:@"%@[]=[%ld]",self.configOption.type?:@"price",lowPrice*r];
            
        }else if (self.higherPrice){
            NSInteger highPrice = self.higherPrice.integerValue;
            if (highPrice > 0) {
                [query appendFormat:@"%@[]=[0,%ld]",self.configOption.type?:@"price",highPrice*r];
            }else {
                [query appendFormat:@"%@[]=[%ld]",self.configOption.type?:@"price",0];
            }
        }else{
            if (self.fromType == FHHouseFindPriceFromTypeHelp) {
                for (NSNumber *index in self.selectIndexes) {
                    if (self.configOption.options.count > index.integerValue) {
                        FHSearchFilterConfigOption *op = self.configOption.options[index.integerValue];
                        if (query.length > 0) {
                            [query appendString:@"&"];
                        }
                        [query appendFormat:@"%@[]=%@",op.type,op.value];
                    }
                }
            }
        }
    }else{
        
        if (!_configOption) {
            return nil;
        }
        
        //帮我找房区域选择特殊处理，需要支持商圈
        if (self.tabId == FHSearchTabIdTypeRegion) {
            NSArray<FHSearchFilterConfigOption *> *options = @[self.configOption];
            __block NSArray<FHSearchFilterConfigOption *> *itemOptions = options.copy;
            for (NSNumber *index in self.selectIndexes) {
                if (itemOptions.count > index.integerValue) {
                    FHSearchFilterConfigOption *op = itemOptions[index.integerValue];
                    if (query.length > 0) {
                        [query appendString:@"&"];
                    }
                    if (op.value) {
                        if ([query containsString:op.type]) {
                            //商圈的“不限”选项op.type=district，直接忽略不上报
                            continue;
                        }
                        [query appendFormat:@"%@[]=%@",op.type,op.value];
                    }
                    itemOptions = itemOptions[index.integerValue].options;
                }
            }
        } else {
            for (NSNumber *index in self.selectIndexes) {
                if (self.configOption.options.count > index.integerValue) {
                    FHSearchFilterConfigOption *op = self.configOption.options[index.integerValue];
                    if (query.length > 0) {
                        [query appendString:@"&"];
                    }
                    [query appendFormat:@"%@[]=%@",op.type,op.value];
                }
            }
        }
        
    }
    
    return [query copy];
}

/**
 将用户选择的结果拼接成一个JSON格式的数据上报给获取线索信息的接口（ f100/api/associate_entrance）
 涉及到一下几个字段：district, area, price, room_num
 数据格式如下：
 {
     "city_id": 1363,
     "district[]": [1364],
     "area[]": [1366],
     "price[]": [[150000,200000], [200000,250000]],
     "room_num[]": [[2,2],[3,3],[4]]
 }
 */
- (NSDictionary *)associateInfoForFindingHouse {
    NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
    if (self.tabId == FHSearchTabIdTypePrice) {
        if (!self.rate) {
            return resultDict;
        }
        
        NSString *key = [NSString stringWithFormat:@"%@[]", self.configOption.type ?: @"price"];
        NSInteger r = self.rate.integerValue;
        if (self.lowerPrice && self.higherPrice) {
            NSInteger lowPrice = self.lowerPrice.integerValue;
            NSInteger highPrice = self.higherPrice.integerValue;
            if (lowPrice > highPrice) {
                NSInteger temp = lowPrice;
                lowPrice = highPrice;
                highPrice = temp;
            }
            
            if (highPrice == 0 && self.fromType == FHHouseFindPriceFromTypeHelp) {
                NSInteger priceNum = lowPrice * r;
                NSString *priceStr = [NSString stringWithFormat:@"%zi", priceNum];
                [resultDict btd_setObject:@[priceStr] forKey:key];
            } else {
                lowPrice = lowPrice * r;
                highPrice = highPrice * r;
                NSString *lowPriceStr = [NSString stringWithFormat:@"%zi", lowPrice];
                NSString *highPriceStr = [NSString stringWithFormat:@"%zi", highPrice];
                [resultDict btd_setObject:@[lowPriceStr, highPriceStr] forKey:key];
            }
        } else if (self.lowerPrice) {
            NSInteger lowPrice = self.lowerPrice.integerValue;
            NSString *lowPriceStr = [NSString stringWithFormat:@"%zi", lowPrice];
            [resultDict btd_setObject:@[lowPriceStr] forKey:key];
        } else if (self.higherPrice) {
            NSInteger highPrice = self.higherPrice.integerValue;
            if (highPrice > 0) {
                NSString *lowPriceStr = @"0";
                NSString *highPriceStr = [NSString stringWithFormat:@"%zi", highPrice];
                [resultDict btd_setObject:@[lowPriceStr, highPriceStr] forKey:key];
            } else {
                [resultDict btd_setObject:@[@"0"] forKey:key];
            }
        } else {
            if (self.fromType == FHHouseFindPriceFromTypeHelp) {
                NSMutableArray *priceArray = [[NSMutableArray alloc] init];
                for (NSNumber *index in self.selectIndexes) {
                    if (self.configOption.options.count > index.integerValue) {
                        FHSearchFilterConfigOption *op = self.configOption.options[index.integerValue];
                        if (op.type.length > 0) {
                            key = [NSString stringWithFormat:@"%@[]", op.type];
                        }
                        if (op.value.length > 0) {
                            NSData *priceData = [op.value dataUsingEncoding:NSUTF8StringEncoding];
                            NSArray *prices = [NSJSONSerialization JSONObjectWithData:priceData options:kNilOptions error:nil];
                            if (prices && [prices isKindOfClass:[NSArray class]]) {
                                [prices enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                    NSString *price = [NSString stringWithFormat:@"%@", obj];
                                    [priceArray btd_addObject:price];
                                }];
                            }
                        }
                    }
                }
                if (priceArray.count > 0) {
                    [resultDict btd_setObject:priceArray forKey:key];
                }
            }
        }
    } else {
        if (!_configOption) {
            return resultDict;
        }
        
        //帮我找房区域选择特殊处理，需要支持商圈
        if (self.tabId == FHSearchTabIdTypeRegion) {
            NSArray<FHSearchFilterConfigOption *> *options = @[self.configOption];
            __block NSArray<FHSearchFilterConfigOption *> *itemOptions = options.copy;
            for (NSNumber *index in self.selectIndexes) {
                if (itemOptions.count > index.integerValue) {
                    FHSearchFilterConfigOption *op = itemOptions[index.integerValue];
                    if (op.value) {
                        if ([resultDict objectForKey:op.type]) {
                            //商圈的“不限”选项op.type=district，直接忽略不上报
                            continue;
                        }
                        NSString *key = [NSString stringWithFormat:@"%@[]", op.type];
                        NSString *value = [NSString stringWithFormat:@"%@", op.value];
                        [resultDict btd_setObject:@[value] forKey:key];
                    }
                    itemOptions = itemOptions[index.integerValue].options;
                }
            }
        } else if (self.tabId == FHSearchTabIdTypeRoom) {
            NSString *roomKey = @"rootm_num[]";
            NSMutableArray *roomArr = [[NSMutableArray alloc] init];
            
            for (NSNumber *index in self.selectIndexes) {
                if (self.configOption.options.count > index.integerValue) {
                    FHSearchFilterConfigOption *op = self.configOption.options[index.integerValue];
                    if (op.type.length > 0) {
                        roomKey = [NSString stringWithFormat:@"%@[]", op.type];
                    }
                    if (op.value.length > 0) {
                        NSString *value = [NSString stringWithFormat:@"%@", op.value];
                        NSData *rootData = [op.value dataUsingEncoding:NSUTF8StringEncoding];
                        NSArray *rooms = [NSJSONSerialization JSONObjectWithData:rootData options:kNilOptions error:nil];
                        NSMutableArray *roomSubArr = [[NSMutableArray alloc] init];
                        if (rooms && [rooms isKindOfClass:[NSArray class]]) {
                            [rooms enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                NSString *room = [NSString stringWithFormat:@"%@", obj];
                                [roomSubArr btd_addObject:room];
                            }];
                            
                            if (roomSubArr.count > 0) {
                                [roomArr btd_addObject:roomSubArr];
                            }
                        }
                    }
                }
            }
            
            [resultDict btd_setObject:roomArr forKey:roomKey];
        }
    }
    
    return resultDict;
}

@end

@implementation FHHouseFindSelectModel

-(instancetype)init
{
    self = [super init];
    if (self) {
        _items = [NSMutableArray new];
    }
    return self;
    
}

-(FHHouseFindSelectItemModel *)selectItemWithTabId:(NSInteger)tabId
{
    for (FHHouseFindSelectItemModel *model in self.items) {
        if (model.tabId == tabId) {
            return model;
        }
    }
    return nil;
}

-(FHHouseFindSelectItemModel *)makeItemWithTabId:(NSInteger)tabId
{
    FHHouseFindSelectItemModel *model = [FHHouseFindSelectItemModel new];
    model.tabId = tabId;
    [self.items addObject:model];
    return model;
}

-(void)addSelecteItem:(FHHouseFindSelectItemModel *)item withIndex:(NSInteger)index
{
    [item.selectIndexes addObject:@(index)];
}

-(void)clearAddSelecteItem:(FHHouseFindSelectItemModel *)item withIndex:(NSInteger)index
{
    [item.selectIndexes removeAllObjects];
    [item.selectIndexes addObject:@(index)];
}

-(void)delSelecteItem:(FHHouseFindSelectItemModel *)item withIndex:(NSInteger)index
{
    [item.selectIndexes removeObject:@(index)];
    if (item.selectIndexes.count == 0) {
        [self.items removeObject:item];
    }
}

-(BOOL)selecteItem:(FHHouseFindSelectItemModel *)item containIndex:(NSInteger)index
{
    return [item.selectIndexes containsObject:@(index)];
}

@end

