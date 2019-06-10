//
//  TTXiguaLiveRecommendWithPicLayout.m
//  Article
//
//  Created by lipeilun on 2017/12/5.
//

#import "TTXiguaLiveRecommendWithPicLayout.h"
#import "TTXiguaLiveHelper.h"

@implementation TTXiguaLiveRecommendWithPicLayout

- (instancetype)init {
    if (self = [super init]) {
        self.minimumLineSpacing = [TTDeviceUIUtils tt_newPadding:3.f];
        self.headerReferenceSize = CGSizeMake(xg_left(), [TTDeviceUIUtils tt_newPadding:245.f]);
        self.footerReferenceSize = CGSizeMake(xg_right(), [TTDeviceUIUtils tt_newPadding:245.f]);
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return self;
}

@end
