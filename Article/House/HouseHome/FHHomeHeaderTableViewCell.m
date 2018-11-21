//
//  FHHomeHeaderTableViewCell.m
//  Article
//
//  Created by 谢飞 on 2018/11/21.
//

#import "FHHomeHeaderTableViewCell.h"
#import "FHHomeCellHelper.h"

@implementation FHHomeHeaderTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.rowsView = [FHRowsView new];
        self.bannerView = [FHHomeBannerView new];
        self.trendView = [FHHomeCityTrendView new];
        self.contentTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [self setUpViews];
    }
    return self;
}

- (void)setUpViews
{
    
    [self addSubview:self.contentTableView];
     self.contentTableView.backgroundColor = [UIColor blueColor];
    [self.contentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [FHHomeCellHelper registerCells:self.contentTableView];
    
    
//    [self addSubview:self.rowsView];
//
//    [self.rowsView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.right.left.equalTo(self);
//        make.height.mas_equalTo(100);
//    }];
//    self.rowsView.backgroundColor = [UIColor redColor];
//
//    [self addSubview:self.bannerView];
//    [self.bannerView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.rowsView.mas_bottom);
//        make.right.left.equalTo(self);
//        make.height.mas_equalTo(100);
//    }];
//    self.bannerView.backgroundColor = [UIColor purpleColor];
//
//
//    [self addSubview:self.trendView];
//    [self.trendView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.bannerView.mas_bottom);
//        make.right.left.equalTo(self);
//        make.height.mas_equalTo(100);
//    }];
//    self.trendView.backgroundColor = [UIColor blueColor];
    
}

- (void)refreshUI
{
    NSInteger num = arc4random()%4;
    switch (num) {
        case 0:
            self.contentTableView.backgroundColor = [UIColor redColor];
            break;
        case 1:
            self.contentTableView.backgroundColor = [UIColor blueColor];
            break;
        case 2:
            self.contentTableView.backgroundColor = [UIColor purpleColor];
            break;
        case 3:
            self.contentTableView.backgroundColor = [UIColor orangeColor];
            break;
        default:
            break;
    }
}

- (void)refreshWithData:(nonnull id)data
{

    
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
