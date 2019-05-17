//
//  TTXiguaLiveRecommendNoPicLayout.m
//  Article
//
//  Created by lipeilun on 2017/12/5.
//

#import "TTXiguaLiveRecommendNoPicLayout.h"
#import "TTXiguaLiveHelper.h"

@implementation TTXiguaLiveRecommendNoPicLayout

- (instancetype)init {
    if (self = [super init]) {
        self.minimumLineSpacing = [TTDeviceUIUtils tt_newPadding:8.f];
        self.headerReferenceSize = CGSizeMake([TTDeviceUIUtils tt_newPadding:12.f], [TTDeviceUIUtils tt_newPadding:131.f]);
        self.footerReferenceSize = CGSizeMake([TTDeviceUIUtils tt_newPadding:12.f], [TTDeviceUIUtils tt_newPadding:131.f]);
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return self;
}

@end
