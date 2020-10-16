//
//  FHNeighborhoodDetailReleatorMoreCell.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/10/14.
//

#import "FHNeighborhoodDetailReleatorMoreCell.h"
#import <ByteDanceKit/ByteDanceKit.h>

@implementation FHNeighborhoodDetailReleatorMoreCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        __weak typeof(self) weakSelf = self;
        self.foldButton = [[FHDetailFoldViewButton alloc] initWithDownText:@"查看全部" upText:@"收起" isFold:YES];
        self.foldButton.openImage = [UIImage imageNamed:@"message_more_arrow"];
        self.foldButton.foldImage = [UIImage imageNamed:@"message_flod_arrow"];
        self.foldButton.keyLabel.textColor = [UIColor colorWithHexString:@"#333333"];
         self.foldButton.keyLabel.font = [UIFont themeFontRegular:16];
        [self.foldButton btd_addActionBlockForTouchUpInside:^(__kindof UIButton * _Nonnull sender) {
            if (weakSelf.foldButtonActionBlock) {
                weakSelf.foldButtonActionBlock();
            }
        }];
        [self.contentView addSubview:self.foldButton];
        [self.foldButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.mas_equalTo(0);
            make.left.right.mas_equalTo(0);
        }];
        [self.foldButton.keyLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(-5);
        }];
    }
    return self;
}

@end
