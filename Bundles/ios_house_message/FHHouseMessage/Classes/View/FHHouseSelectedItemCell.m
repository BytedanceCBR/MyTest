//
//  FHHouseSelectedItemCell.m
//  FHHouseMessage
//
//  Created by leo on 2019/4/29.
//

#import "FHHouseSelectedItemCell.h"
#import "Masonry.h"
@interface FHHouseSelectedItemCell ()
@property (nonatomic, strong) UIImageView* checkView;
@end

@implementation FHHouseSelectedItemCell

- (void)initUI {
    [super initUI];
    self.checkView = [[UIImageView alloc] init];
    _checkView.image = [UIImage imageNamed:@"fh_im_share_unchecked2"];
    [self.contentView addSubview:_checkView];
    [_checkView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mainImageView).mas_equalTo(-6);
        make.top.mas_equalTo(self.mainImageView).mas_offset(6);
        make.width.height.mas_equalTo(20);
    }];
}

-(void)setItemSelected:(BOOL)itemSelected {
    if (itemSelected) {
        _checkView.image = [UIImage imageNamed:@"fh_im_share_checked2"];
    } else {
        _checkView.image = [UIImage imageNamed:@"fh_im_share_unchecked2"];
    }
}

-(void)setDisable:(BOOL)isDisable {
    if (isDisable) {
        self.contentView.alpha = 0.3;
    } else {
        self.contentView.alpha = 1;
    }
}

@end
