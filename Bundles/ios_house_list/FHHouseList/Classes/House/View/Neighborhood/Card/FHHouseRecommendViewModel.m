//
//  FHHouseRecommendViewModel.m
//  FHHouseList
//
//  Created by xubinbin on 2020/11/26.
//

#import "FHHouseRecommendViewModel.h"

@interface FHHouseRecommendViewModel()

@property (nonatomic, strong) FHHouseListHouseAdvantageTagModel *model;

@end

@implementation FHHouseRecommendViewModel

- (instancetype)initWithModel:(FHHouseListHouseAdvantageTagModel *)model {
    self = [super init];
    if (self) {
        _model = model;
    }
    return self;
}

- (NSString *)text {
    return self.model.text;
}

- (NSString *)url {
    return self.model.icon.url;
}

- (BOOL)isHidden {
    if (self.model && ([self.model.text length] > 0 || (self.model.icon && [self.model.icon.url length] > 0))) {
        return NO;
    }
    return YES;
}

- (CGFloat)showSecondHouseHeight {
    if (![self isHidden]) {
        return 25;
    } else {
        return 0;
    }
}

- (CGFloat)showNewHouseHeight {
    if (![self isHidden]) {
        return 22;
    } else {
        return 0;
    }
}

- (CGFloat)showHeight {
    return 0;
}

@end
