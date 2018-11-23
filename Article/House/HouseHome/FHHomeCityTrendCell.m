//
//  FHHomeCityTrendCell.m
//  Article
//
//  Created by 谢飞 on 2018/11/21.
//

#import "FHHomeCityTrendCell.h"

#import "FHHomeCityTrendView.h"
#import "FHConfigModel.h"

@interface FHHomeCityTrendCell()



@end

@implementation FHHomeCityTrendCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

-(void)setupUI {
    
    self.trendView = [[FHHomeCityTrendView alloc]initWithFrame:self.contentView.bounds];
    [self.contentView addSubview:self.trendView];

}

-(void)updateWithModel:(FHConfigDataCityStatsModel *)model {
    
    [self.trendView updateWithModel:model];
}

-(CGSize)sizeThatFits:(CGSize)size {
    
    [super sizeThatFits:size];
    CGSize theSize = CGSizeMake(size.width, 64 + 25);

    return theSize;
}

-(void)layoutSubviews {
    
    [super layoutSubviews];
    self.trendView.size = CGSizeMake(self.contentView.bounds.size.width, 64);
    self.trendView.left = 0;
    self.trendView.top = 15;
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
