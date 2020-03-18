//
//  FHDetailNewHouseNewsCell.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/15.
//

#import "FHDetailNewHouseNewsCell.h"
#import "TTRoute.h"

@interface FHDetailNewHouseNewsCell ()

@property (nonatomic, weak) UIImageView *shadowImage;

@end

@implementation FHDetailNewHouseNewsCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.shadowImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.contentView);
            make.right.mas_equalTo(self.contentView);
            make.top.equalTo(self.contentView).offset(-12);
            make.bottom.equalTo(self.contentView).offset(12);
        }];
        _headerView = [[FHDetailHeaderView alloc] init];
        [self.contentView addSubview:_headerView];
        [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.shadowImage).offset(30);
            make.right.mas_equalTo(self.shadowImage).offset(-15);
            make.left.mas_equalTo(self.shadowImage).offset(15);
            make.height.mas_equalTo(46);
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

        adjustImageScopeType(model)
        
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
