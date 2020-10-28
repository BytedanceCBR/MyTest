//
//  FHHouseNewBillboardContentViewModel.m
//  AKCommentPlugin
//
//  Created by bytedance on 2020/10/27.
//

#import "FHHouseNewBillboardContentViewModel.h"
#import "FHSearchHouseModel.h"
#import "FHHouseNewBillboardItemViewModel.h"

@interface FHHouseNewBillboardContentViewModel() {
    NSMutableArray *_itemList;
}
@property (nonatomic, strong) FHCourtBillboardPreviewModel *model;
@end

@implementation FHHouseNewBillboardContentViewModel

- (instancetype)initWithModel:(FHCourtBillboardPreviewModel *)model {
    self = [super init];
    if (self) {
        _model = model;
        _itemList = [NSMutableArray array];
        for (FHCourtBillboardPreviewItemModel *itemModel in model.items) {
            FHHouseNewBillboardItemViewModel *viewModel = [[FHHouseNewBillboardItemViewModel alloc] initWithModel:itemModel];
            [_itemList addObject:viewModel];
        }
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

- (void)onClickButton {
    
}

- (BOOL)isValid {
    return (self.title.length > 0 && self.buttonText.length > 0 && self.items.count > 0);
}

@end
