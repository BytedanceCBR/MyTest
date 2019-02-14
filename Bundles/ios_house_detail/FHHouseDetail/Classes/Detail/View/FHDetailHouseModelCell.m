//
//  FHDetailHouseModelCell.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/13.
//

#import "FHDetailHouseModelCell.h"
#import "TTRoute.h"
#import "FHDetailNewModel.h"

@interface FHDetailHouseModelCell()

@property (nonatomic , strong) NSMutableArray <FHDetailNewDataFloorpanListListModel *> *allItems;

@end

@implementation FHDetailHouseModelCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setUpCollection];
    }
    return self;
}

- (void)setUpCollection
{
    UIView *view = [UIView new];
    [self.contentView addSubview:view];
    
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.equalTo(self.contentView);
        make.height.mas_equalTo(100);
    }];
    
    [view setBackgroundColor:[UIColor redColor]];
    
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick)];
    [view addGestureRecognizer:tapGes];
}

- (void)refreshWithData:(id)data
{
    if ([data isKindOfClass:[FHDetailNewDataFloorpanListModel class]]) {
        _allItems = [NSArray arrayWithArray:((FHDetailNewDataFloorpanListModel *)data).list];
    }
}

- (void)tapClick
{
    TTRouteUserInfo *info = [[TTRouteUserInfo alloc] initWithInfo:@{@"floorlist":self.allItems}];
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://floor_pan_list"] userInfo:info];
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
