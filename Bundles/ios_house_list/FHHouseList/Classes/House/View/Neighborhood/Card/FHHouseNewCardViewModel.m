//
//  FHHouseNewCardViewModel.m
//  FHHouseList
//
//  Created by xubinbin on 2020/11/27.
//

#import "FHHouseNewCardViewModel.h"
#import "FHCommonDefines.h"
#import "FHHouseRecommendViewModel.h"

@implementation FHHouseNewCardViewModel

- (instancetype)initWithModel:(FHSearchHouseItemModel *)model {
    self = [super init];
    if (self) {
        _model = model;
        _recommendViewModel = [[FHHouseRecommendViewModel alloc] initWithModel:model.advantageDescription];
    }
    return self;
}

- (FHImageModel *)leftImageModel {
    return [self.model.images firstObject];
}

- (NSString *)title {
    return self.model.displayTitle;
}

- (NSString *)price {
    return self.model.displayPricePerSqm;
}

- (NSString *)subtitle {
    return self.model.displayDescription;
}

- (NSArray<FHHouseTagsModel *> *)tagList {
    return self.model.tags;
}

- (BOOL)hasVr {
    return self.model.vrInfo.hasVr;
}

- (BOOL)hasVideo {
    if (![self hasVr]) {
        return self.model.videoInfo.hasVideo;
    } else {
        return NO;
    }
}

- (NSString *)propertyText {
    return self.model.propertyTag.content;
}

- (NSString *)propertyBorderColor {
    return self.model.propertyTag.borderColor;
}

@end
