//
//  FHHouseNewBillboardItemViewModel.m
//  AKCommentPlugin
//
//  Created by bytedance on 2020/10/27.
//

#import "FHHouseNewBillboardItemViewModel.h"
#import "FHSearchHouseModel.h"

@interface FHHouseNewBillboardItemViewModel()
@property (nonatomic, strong) FHCourtBillboardPreviewItemModel *model;
@end

@implementation FHHouseNewBillboardItemViewModel

- (instancetype)initWithModel:(FHCourtBillboardPreviewItemModel *)model {
    self = [super init];
    if (self) {
        _model = model;
    }
    return self;
}

- (NSString *)title {
    return self.model.title;
}

- (NSString *)subtitle {
    return self.model.subtitle;
}

- (NSString *)detail {
    return self.model.pricingPerSqm;;
}

- (FHImageModel *)img {
    return self.model.img;
}

- (void)onClickView {
    
}

- (BOOL)isValid {
    return (self.title.length > 0 && self.subtitle.length > 0 && self.detail.length > 0);
}

@end
