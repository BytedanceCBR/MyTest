//
//  FHDetailSectionRelatedTitleCollectionView.m
//  FHHouseDetail
//
//  Created by xubinbin on 2020/11/27.
//

#import "FHDetailSectionRelatedTitleCollectionView.h"
#import <FHCommonUI/UIColor+Theme.h>
#import <FHCommonUI/UIFont+House.h>
#import <Masonry/Masonry.h>

@implementation FHDetailSectionRelatedTitleCollectionView

- (void)prepareForReuse {
    [super prepareForReuse];
    self.arrowsImg.hidden = YES;
    self.subTitleLabel.hidden = YES;
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(20);
    }];
}

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
