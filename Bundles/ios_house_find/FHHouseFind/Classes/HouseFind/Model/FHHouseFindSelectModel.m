//
//  FHHouseFindSelectModel.m
//  FHHouseFind
//
//  Created by 春晖 on 2019/2/13.
//

#import "FHHouseFindSelectModel.h"

@implementation FHHouseFindSelectItemModel

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
                NSString *ptemp = self.lowerPrice;
                self.lowerPrice = self.higherPrice;
                self.higherPrice = ptemp;
            }
            [query appendFormat:@"%@[]=[%ld,%ld]",self.configOption.type?:@"price",lowPrice*r,highPrice*r];
            
        }else if (self.lowerPrice){
            NSInteger lowPrice = self.lowerPrice.integerValue;
            [query appendFormat:@"%@[]=[%ld]",self.configOption.type?:@"price",lowPrice*r];
            
        }else if (self.higherPrice){
            NSInteger highPrice = self.higherPrice.integerValue;
            [query appendFormat:@"%@[]=[0,%ld]",self.configOption.type?:@"price",highPrice*r];
        }else{
            return nil;
//            [query appendFormat:@"%@[]=[]",self.configOption.type?:@"price"];
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

