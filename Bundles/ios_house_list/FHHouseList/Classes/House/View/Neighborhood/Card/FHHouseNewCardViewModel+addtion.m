//
//  FHHouseNewCardViewModel+addtion.m
//  FHHouseList
//
//  Created by xubinbin on 2020/11/27.
//

#import "FHHouseNewCardViewModel+addtion.h"

@implementation FHHouseNewCardViewModel (addtion)

- (BOOL)isOffShelf {
    if ([self.model isKindOfClass:[FHSearchHouseItemModel class]]) {
        return ((FHSearchHouseItemModel *)self.model).houseStatus.integerValue == 1 ? YES : NO;
    }
    return NO;
}

@end
