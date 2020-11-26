//
//  FHHouseNewCardViewModel+addtion.m
//  FHHouseList
//
//  Created by xubinbin on 2020/11/27.
//

#import "FHHouseNewCardViewModel+addtion.h"

@implementation FHHouseNewCardViewModel (addtion)

- (BOOL)isOffShelf {
    return self.model.houseStatus.integerValue == 1 ? YES : NO;
}

@end
