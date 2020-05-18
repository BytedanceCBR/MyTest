//
//  FHCommunityBaseViewModel.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/4/20.
//

#import "FHCommunityBaseViewModel.h"

@interface FHCommunityBaseViewModel ()

@end

@implementation FHCommunityBaseViewModel

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView controller:(UIViewController *)viewController {
    self = [super init];
    if (self) {
        self.isFirstLoad = YES;
        self.collectionView = collectionView;
        self.viewController = (FHCommunityViewController *)viewController;
    }
    return self;
}

- (void)viewWillAppear {
    
}

- (void)viewWillDisappear {
    
}

- (void)refreshCell:(BOOL)isHead isClick:(BOOL)isClick {
    
}

- (void)segmentViewIndexChanged:(NSInteger)index {
    
}

- (void)changeTab:(NSInteger)index {
    
}

- (NSArray *)getSegmentTitles {
    return nil;
}


- (NSString *)pageType {
    NSString *page_type = UT_BE_NULL;
    return page_type;
}

@end
