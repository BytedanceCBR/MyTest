//
//  FHDetailNewHouseNewsCell.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/15.
//

#import "FHDetailNewHouseNewsCell.h"
#import "FHDetailHeaderView.h"

@interface FHDetailNewHouseNewsCell ()
@property (nonatomic, strong) FHDetailHeaderView *headerView;
@end

@implementation FHDetailNewHouseNewsCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        _headerView = [[FHDetailHeaderView alloc] init];
        _headerView.label.text = @"楼盘动态";
        _headerView.isShowLoadMore = YES;
        [self.contentView addSubview:_headerView];
        [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.bottom.mas_equalTo(self.contentView);
            make.height.mas_equalTo(52);// 46 + 6
        }];
        [_headerView setBackgroundColor:[UIColor whiteColor]];
    }
    return self;
}

- (void)refreshWithData:(id)data
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

@implementation FHDetailNewHouseNewsCellModel
@end
