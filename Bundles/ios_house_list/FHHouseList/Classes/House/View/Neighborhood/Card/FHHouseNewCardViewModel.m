//
//  FHHouseNewCardViewModel.m
//  FHHouseList
//
//  Created by xubinbin on 2020/11/27.
//

#import "FHHouseNewCardViewModel.h"
#import "FHCommonDefines.h"
#import "FHHouseRecommendViewModel.h"

@interface FHHouseNewCardViewModel()

@property (nonatomic, strong) FHImageModel *leftImageModel;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *propertyText;

@property (nonatomic, copy) NSString *propertyBorderColor;

@property (nonatomic, copy) NSString *subtitle;

@property (nonatomic, copy) NSString *price;

@property (nonatomic, copy) NSString *pricePerSqm;

@property (nonatomic, strong) NSArray<FHHouseTagsModel *> *tagList;

@property (nonatomic, assign) BOOL hasVr;

@property (nonatomic, assign) BOOL hasVideo;

@end

@implementation FHHouseNewCardViewModel

- (instancetype)initWithModel:(id)model {
    self = [super init];
    if (self) {
        _model = model;
        if ([model isKindOfClass:[FHSearchHouseItemModel class]]) {
            FHSearchHouseItemModel *item = (FHSearchHouseItemModel *)model;
            _recommendViewModel = [[FHHouseRecommendViewModel alloc] initWithModel:item.advantageDescription];
            self.leftImageModel = [item.images firstObject];
            self.title = item.displayTitle;
            self.price = item.displayPricePerSqm;
            self.subtitle = item.displayDescription;
            self.tagList = item.tags;
            self.hasVr = item.vrInfo.hasVr;
            self.hasVideo = !self.hasVr && item.videoInfo.hasVideo;
            self.propertyText = item.propertyTag.content;
            self.propertyBorderColor = item.propertyTag.borderColor;
        } else if ([model isKindOfClass:[FHHouseListBaseItemModel class]]) {
            FHHouseListBaseItemModel *item = (FHHouseListBaseItemModel *)model;
            _recommendViewModel = [[FHHouseRecommendViewModel alloc] initWithModel:item.advantageDescription];
            self.leftImageModel = [item.houseImage firstObject];
            self.title = item.title;
            self.price = item.displayPricePerSqm;
            self.subtitle = item.displaySubtitle;
            self.tagList = item.tags;
        }
    }
    return self;
}

@end
