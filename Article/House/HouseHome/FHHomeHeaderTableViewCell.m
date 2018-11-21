//
//  FHHomeHeaderTableViewCell.m
//  Article
//
//  Created by 谢飞 on 2018/11/21.
//

#import "FHHomeHeaderTableViewCell.h"

@implementation FHHomeHeaderTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.rowsView = [FHRowsView new];
        self.bannerView = [FHHomeBannerView new];
        self.trendView = [FHHomeCityTrendView new];
        
        [self setUpViews];
    }
    return self;
}

- (void)setUpViews
{
    [self addSubview:self.rowsView];
    
    [self.rowsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.left.equalTo(self);
        make.height.mas_equalTo(100);
    }];
    self.rowsView.backgroundColor = [UIColor redColor];
    
    [self addSubview:self.bannerView];
    [self.bannerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.rowsView.mas_bottom);
        make.right.left.equalTo(self);
        make.height.mas_equalTo(100);
    }];
    self.bannerView.backgroundColor = [UIColor purpleColor];
    
    
    [self addSubview:self.trendView];
    [self.trendView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bannerView.mas_bottom);
        make.right.left.equalTo(self);
        make.height.mas_equalTo(100);
    }];
    self.trendView.backgroundColor = [UIColor blueColor];
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
