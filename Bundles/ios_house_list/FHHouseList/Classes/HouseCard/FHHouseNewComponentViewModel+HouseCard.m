//
//  FHHouseNewComponentViewModel+HouseCard.m
//  FHHouseList
//
//  Created by bytedance on 2020/12/2.
//

#import "FHHouseNewComponentViewModel+HouseCard.h"
#import <objc/runtime.h>

@implementation FHHouseNewComponentViewModel(HouseCard)
static const char model_key, card_index_key, card_count_key;
- (instancetype)initWithModel:(id)model {
    self = [super init];
    if (self) {
        [self setModel:model];
    }
    return self;
}

- (void)setModel:(id)model {
    objc_setAssociatedObject(self, &model_key, model, OBJC_ASSOCIATION_RETAIN);
}

- (id)model {
    return objc_getAssociatedObject(self, &model_key);
}

- (void)setCardIndex:(NSInteger)cardIndex {
    objc_setAssociatedObject(self, &card_index_key, @(cardIndex), OBJC_ASSOCIATION_RETAIN);
}

- (NSInteger)cardIndex {
    return [objc_getAssociatedObject(self, &card_index_key) integerValue];
}

- (void)setCardCount:(NSInteger)cardCount {
    objc_setAssociatedObject(self, &card_count_key, @(cardCount), OBJC_ASSOCIATION_RETAIN);
}

- (NSInteger)cardCount {
    return [objc_getAssociatedObject(self, &card_count_key) integerValue];
}
@end
