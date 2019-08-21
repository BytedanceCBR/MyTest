//
//  FHMapSearchSelectModel.m
//  DemoFunTwo
//
//  Created by 春晖 on 2019/7/10.
//  Copyright © 2019 chunhui. All rights reserved.
//

#import "FHMapSearchSelectModel.h"

@implementation FHMapSearchSelectItemModel

-(instancetype)init
{
    self = [super init];
    if (self) {
        _selectIndexes = [NSMutableSet new];
    }
    return self;
}

-(NSString *)selectQuery
{
    NSMutableString *query = [[NSMutableString alloc] init];
    if (self.tabId == FHMapSearchTabIdTypePrice) {
        
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
            if (highPrice == 0 ) {//&& self.fromType == FHHouseFindPriceFromTypeHelp
                [query appendFormat:@"%@[]=[%ld]",self.configOption.type?:@"price",lowPrice*r];
            }else {
                [query appendFormat:@"%@[]=[%ld,%ld]",self.configOption.type?:@"price",lowPrice*r,highPrice*r];
            }
            
        }else if (self.lowerPrice){
            NSInteger lowPrice = self.lowerPrice.integerValue;
            [query appendFormat:@"%@[]=[%ld]",self.configOption.type?:@"price",lowPrice*r];
            
        }else if (self.higherPrice){
            NSInteger highPrice = self.higherPrice.integerValue;
            [query appendFormat:@"%@[]=[0,%ld]",self.configOption.type?:@"price",highPrice*r];
        }else{
//            if (self.fromType == FHHouseFindPriceFromTypeHelp) {
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
//            }
        }
        
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

@end

@implementation FHMapSearchSelectModel

-(instancetype)init
{
    self = [super init];
    if (self) {
        _items = [NSMutableArray new];
    }
    return self;
    
}

-(FHMapSearchSelectItemModel *)selectItemWithTabId:(NSInteger)tabId  section:(NSInteger)section
{
    for (FHMapSearchSelectItemModel *model in self.items) {
        if (model.tabId == tabId && model.section == section) {
            return model;
        }
    }
    return nil;
}

-(FHMapSearchSelectItemModel *)makeItemWithTabId:(NSInteger)tabId  section:(NSInteger)section
{
    FHMapSearchSelectItemModel *model = [FHMapSearchSelectItemModel new];
    model.tabId = tabId;
    model.section = section;
    [self.items addObject:model];
    return model;
}

-(void)addSelecteItem:(FHMapSearchSelectItemModel *)item withIndex:(NSInteger)index
{
    [item.selectIndexes addObject:@(index)];
}

-(void)clearAddSelecteItem:(FHMapSearchSelectItemModel *)item withIndex:(NSInteger)index
{
    [item.selectIndexes removeAllObjects];
    [item.selectIndexes addObject:@(index)];
}

-(void)delSelecteItem:(FHMapSearchSelectItemModel *)item withIndex:(NSInteger)index
{
    [item.selectIndexes removeObject:@(index)];
    if (item.selectIndexes.count == 0) {
        [self.items removeObject:item];
    }
}

-(BOOL)selecteItem:(FHMapSearchSelectItemModel *)item containIndex:(NSInteger)index
{
    return [item.selectIndexes containsObject:@(index)];
}

-(void)clearAllSection
{
    [self.items removeAllObjects];
}

-(NSString *)selectedQuery
{
    if (self.items.count > 0) {
        NSMutableString *mquery = [[NSMutableString alloc] init];
        for (FHMapSearchSelectItemModel *item in _items) {
            NSString *query = [item selectQuery];
            if (query.length == 0) {
                continue;
            }
            if (mquery.length > 0) {
                [mquery appendString:@"&"];
            }
            [mquery appendString:query];
        }
        return mquery;
    }
    
    return nil;
}

@end


