//
//  FHPictureListTitleCollectionView.m
//  Pods
//
//  Created by bytedance on 2020/5/21.
//

#import "FHDetailSectionTitleCollectionView.h"
#import <FHCommonUI/UIColor+Theme.h>
#import <FHCommonUI/UIFont+House.h>
#import <Masonry/Masonry.h>

@implementation FHDetailSectionTitleCollectionView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.font = [UIFont themeFontRegular:14];
        self.titleLabel.textColor = [UIColor colorWithHexStr:@"#6d7278"];
        [self addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.centerY.mas_equalTo(self);
        }];
        
        self.arrowsImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrowicon-feed-4"]];
        self.arrowsImg.hidden = YES;
        [self addSubview:self.arrowsImg];
        [self.arrowsImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self).offset(-12);
            make.height.width.mas_equalTo(20);
            make.centerY.mas_equalTo(self);
        }];
        
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(moreAction:)]];
    }
    return self;
}

- (void)moreAction:(UITapGestureRecognizer *)tapGesture {
    if (self.moreActionBlock) {
        self.moreActionBlock();
    }
}

@end
