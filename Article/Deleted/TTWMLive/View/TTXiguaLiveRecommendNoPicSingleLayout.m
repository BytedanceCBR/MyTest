//
//  TTXiguaLiveRecommendNoPicSingleLayout.m
//  Article
//
//  Created by lipeilun on 2017/12/7.
//

#import "TTXiguaLiveRecommendNoPicSingleLayout.h"

@implementation TTXiguaLiveRecommendNoPicSingleLayout
- (instancetype)init {
    if (self = [super init]) {
        self.sectionInset = UIEdgeInsetsMake([TTDeviceUIUtils tt_newPadding:5.f], 0, 0, 0);
        self.headerReferenceSize = CGSizeMake([TTDeviceUIUtils tt_newPadding:12.f], [TTDeviceUIUtils tt_newPadding:94.f]);
        self.footerReferenceSize = CGSizeMake([TTDeviceUIUtils tt_newPadding:12.f], [TTDeviceUIUtils tt_newPadding:94.f]);
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.minimumLineSpacing = [TTDeviceUIUtils tt_newPadding:8.f];
    }
    return self;
}
@end
