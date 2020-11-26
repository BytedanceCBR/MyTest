//
//  FHHouseRecommendViewModel.m
//  FHHouseList
//
//  Created by xubinbin on 2020/11/26.
//

#import "FHHouseRecommendViewModel.h"
#import "FHSearchHouseModel.h"

@interface FHHouseRecommendViewModel()

@property (nonatomic, strong) FHSearchHouseItemModel *model;

@end

@implementation FHHouseRecommendViewModel

- (instancetype)initWithModel:(FHSearchHouseItemModel *)model {
    self = [super init];
    if (self) {
        _model = model;
    }
    return self;
}

- (NSString *)text {
    return self.model.advantageDescription.text;
}

- (NSString *)url {
    return self.model.advantageDescription.icon.url;
}

- (BOOL)isHidden {
    FHHouseListHouseAdvantageTagModel *adModel = self.model.advantageDescription;
    if ([adModel.text length] > 0 || (adModel.icon && [adModel.icon.url length] > 0)) {
        return NO;
    }
    return YES;
}

- (CGFloat)showHeight {
    if (![self isHidden]) {
        return 35;
    } else {
        return 10;
    }
}

@end
