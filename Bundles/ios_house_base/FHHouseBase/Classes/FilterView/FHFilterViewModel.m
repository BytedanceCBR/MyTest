//
//  FHFilterViewModel.m
//  FHHouseBase
//
//  Created by leo on 2018/11/17.
//  Copyright © 2018 com.haoduofangs. All rights reserved.
//

#import "FHFilterViewModel.h"
#import "FilterItemBar.h"
#import "FHFilterContainerPanel.h"
#import <ReactiveObjC/ReactiveObjC.h>

@interface FHFilterViewModel ()<FilterItemBarStateChangedDelegate>

@end

@implementation FHFilterViewModel

+ (instancetype)instanceWithItemBar:(FilterItemBar*)bar
                          withPanel:(FHFilterContainerPanel*)panel
{
    FHFilterViewModel* result = [[FHFilterViewModel alloc] initWithItemBar:bar
                                                                 withPanel:panel];
    return result;
}

- (instancetype)initWithItemBar:(FilterItemBar*)bar
                      withPanel:(FHFilterContainerPanel*)panel
{
    self = [super init];
    if (self) {
        self.filterItemBar = bar;
        self.filterPanel = panel;
        _filterItemBar.stateChangedDelegate = self;
        [self bindPanelTouchAction];
    }
    return self;
}

- (void)bindPanelTouchAction {
    [_filterPanel addTarget:self
                     action:@selector(onFilterConditionPanelTouched:)
           forControlEvents:UIControlEventTouchUpInside];
}

- (void)onFilterConditionPanelTouched:(id)sender {
    [self closePanel];
}


- (void)onPanelExpand:(BOOL)isExpand {
    [_filterPanel setHidden: !isExpand];
}

-(void)closePanel {
    [_filterItemBar packUp];
}

@end
