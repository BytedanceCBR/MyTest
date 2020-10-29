//
//  FHHouseNewEntrancesViewModel.m
//  AKCommentPlugin
//
//  Created by bytedance on 2020/10/27.
//

#import "FHHouseNewEntrancesViewModel.h"
#import "FHEnvContext.h"

@interface FHHouseNewEntrancesViewModel()
@property (nonatomic, strong, readwrite) NSArray *items;
@end

@implementation FHHouseNewEntrancesViewModel

- (NSArray *)items {
    if (!_items) {
        FHConfigDataModel *configModel = [[FHEnvContext sharedInstance] getConfigFromCache];
        NSArray *items = configModel.houseOpData2.items;
        if (items.count > 5) {
            items = [items subarrayWithRange:NSMakeRange(0, 5 )];
        }
    
        _items = items;
    }
    
    return _items;
}

- (BOOL)isValid {
    return self.items.count > 0;
}

- (void)onClickItem:(FHConfigDataOpDataItemsModel *)item {
    
}

@end
