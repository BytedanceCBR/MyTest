//
//  FHHouseNewBillboardContentViewModel.m
//  AKCommentPlugin
//
//  Created by bytedance on 2020/10/27.
//

#import "FHHouseNewBillboardContentViewModel.h"
#import "FHSearchHouseModel.h"
#import "FHHouseNewBillboardItemViewModel.h"
#import "NSObject+FHTracker.h"
#import "FHHouseOpenURLUtil.h"
#import "NSString+BTDAdditions.h"
#import "NSURL+BTDAdditions.h"
#import "NSDictionary+BTDAdditions.h"
#import "FHHouseNewBillboardTrackDefines.h"
#import "FHUserTracker.h"

@interface FHHouseNewBillboardContentViewModel() {
    NSMutableArray *_itemList;
}
@property (nonatomic, strong) FHCourtBillboardPreviewModel *model;
@property (nonatomic, assign) BOOL showed;
@end

@implementation FHHouseNewBillboardContentViewModel

- (instancetype)initWithModel:(FHCourtBillboardPreviewModel *)model tracerModel:(FHTracerModel *)tracerModel {
    self = [super init];
    if (self) {
        _model = model;
        _itemList = [NSMutableArray array];
        for (NSInteger index = 0; index < model.items.count; index++) {
            FHCourtBillboardPreviewItemModel *itemModel = model.items[index];
            FHHouseNewBillboardItemViewModel *viewModel = [[FHHouseNewBillboardItemViewModel alloc] initWithModel:itemModel];
            viewModel.itemIndex = index;
            viewModel.fh_trackModel = tracerModel;
            [_itemList addObject:viewModel];
        }
        
        [self setFh_trackModel:tracerModel];
    }
    return self;
}

- (NSString *)title {
    return self.model.title;
}

- (NSArray<FHHouseNewBillboardItemViewModel *> *)items {
    return _itemList;
}

- (NSString *)buttonText {
    return self.model.button.text;
}

- (void)onShowView {
    if (!self.showed) {
        self.showed = YES;
        NSMutableDictionary *logParams = [NSMutableDictionary dictionary];
        logParams[UT_PAGE_TYPE] = self.fh_trackModel.pageType ? : @"be_null";
        logParams[UT_ELEMENT_TYPE] = UT_ELEMENT_TYPE_BILLBOARD;
        [FHUserTracker writeEvent:UT_EVENT_BILLBOARD_SHOW params:logParams];
    }
}

- (void)onClickButton {
    NSString *openUrl = self.model.button.openUrl;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[UT_ENTER_FROM] = self.fh_trackModel.pageType ? : @"be_null";
    dict[UT_ORIGIN_FROM] = self.fh_trackModel.originFrom ? : @"be_null";
    dict[UT_ELEMENT_FROM] = UT_ELEMENT_TYPE_BILLBOARD;
    [FHHouseOpenURLUtil openUrl:openUrl logParams:dict];
}

- (BOOL)isValid {
    return (self.title.length > 0 && self.buttonText.length > 0 && self.items.count > 0);
}

@end
