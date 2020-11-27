//
//  FHDetailSectionRelatedTitleCollectionView.m
//  FHHouseDetail
//
//  Created by xubinbin on 2020/11/27.
//

#import "FHDetailSectionRelatedTitleCollectionView.h"
#import <Masonry/Masonry.h>

@implementation FHDetailSectionRelatedTitleCollectionView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.top.mas_equalTo(20);
        }];
    }
    return self;
}

@end
