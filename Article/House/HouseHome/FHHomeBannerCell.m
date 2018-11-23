//
//  FHHomeBannerCell.m
//  Article
//
//  Created by 谢飞 on 2018/11/21.
//

#import "FHHomeBannerCell.h"

@implementation FHHomeBannerCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.bannerView = [[FHHomeBannerView alloc] initWithRowCount:2 withRowHight:70];
        [self setUpSubViews];
    }
    return self;
}

- (void)setUpSubViews
{
    [self.contentView addSubview:_bannerView];
    _bannerView.backgroundColor = [UIColor whiteColor];
    
    [_bannerView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.left.top.right.equalTo(self.contentView);
//        make.centerY.equalTo(self.contentView);
//        make.height.mas_equalTo(70);
        make.edges.mas_equalTo(self.contentView);
    }];
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
