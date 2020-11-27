//
//  FHHouseSecondCardViewModel+addtion.m
//  FHHouseList
//
//  Created by xubinbin on 2020/11/26.
//

#import "FHHouseSecondCardViewModel+addtion.h"

@implementation FHHouseSecondCardViewModel (addtion)

- (BOOL)isOffShelf {
    if ([self.model isKindOfClass:[FHSearchHouseItemModel class]]) {
        return ((FHSearchHouseItemModel *)self.model).houseStatus.integerValue == 1 ? YES : NO;
    }
    return NO;
}

@end
