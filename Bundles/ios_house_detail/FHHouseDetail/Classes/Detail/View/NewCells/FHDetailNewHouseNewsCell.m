//
//  FHDetailNewHouseNewsCell.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/15.
//

#import "FHDetailNewHouseNewsCell.h"
#import <TTRoute.h>

@interface FHDetailNewHouseNewsCell ()
@end

@implementation FHDetailNewHouseNewsCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        _headerView = [[FHDetailHeaderView alloc] init];
        [self.contentView addSubview:_headerView];
        [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.bottom.mas_equalTo(self.contentView);
            make.height.mas_equalTo(52);// 46 + 6
        }];
        [_headerView addTarget:self action:@selector(moreButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_headerView setBackgroundColor:[UIColor whiteColor]];
    }
    return self;
}

- (void)refreshWithData:(id)data
{
    if ([data isKindOfClass:[FHDetailNewHouseNewsCellModel class]]) {
        self.currentData = data;
        FHDetailNewHouseNewsCellModel *model = (FHDetailNewHouseNewsCellModel *)data;
        _headerView.label.text = model.titleText;
        
        _headerView.isShowLoadMore = model.hasMore;
    }
}

- (NSString *)elementTypeString:(FHHouseType)houseType
{
    if ([_headerView.label.text isEqualToString:@"楼盘动态"]) {
        return @"house_history";
    }
    return @"related";
}


// 查看更多
- (void)moreButtonClick:(UIButton *)button {
    FHDetailNewHouseNewsCellModel *model = (FHDetailNewHouseNewsCellModel *)self.currentData;

    if (model && model.clickEnable) {
        NSString *courtId = ((FHDetailNewHouseNewsCellModel *)self.currentData).courtId;
        
        NSDictionary *dict = [self.baseViewModel subPageParams];
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc]initWithInfo:dict];
        [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:[NSString stringWithFormat:@"sslocal://floor_timeline_detail?court_id=%@",courtId]] userInfo:userInfo];
    }

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
