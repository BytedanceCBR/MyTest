//
//  FHHomeSearchPanelViewModel.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2018/12/22.
//

#import "FHHomeSearchPanelViewModel.h"

@interface FHHomeSearchPanelViewModel ()

@property(nonatomic, strong) FHHomeSearchPanelView *suspendSearchBar;
@property(nonatomic, strong) NSString *currentCityName;

@end

@implementation FHHomeSearchPanelViewModel

- (instancetype)initWithSearchPanel:(FHHomeSearchPanelView *)panel
{
    self = [super init];
    if (self) {
        self.suspendSearchBar = panel;
    }
    return self;
}

@end
