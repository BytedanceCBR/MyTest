//
//  FHDetailNeighborhoodOwnerSellHouseCell.m
//  FHHouseDetail
//
//  Created by bytedance on 2020/9/6.
//

#import "FHDetailNeighborhoodOwnerSellHouseCell.h"
#import "FHCommonDefines.h"

@interface FHDetailNeighborhoodOwnerSellHouseCell ()
@property(nonatomic,strong) UIImageView *helpMeSellHouseImageView;

@end

@implementation FHDetailNeighborhoodOwnerSellHouseCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

-(void)setupUI {
    UIImage *helpMeSellHouseImage = [UIImage imageNamed:@"helpMeSellHouse"];
    _helpMeSellHouseImageView = [[UIImageView alloc] initWithImage:helpMeSellHouseImage];
    CGFloat imageHeight = helpMeSellHouseImage.size.height * SCREEN_WIDTH / helpMeSellHouseImage.size.width;
    [self.contentView addSubview:_helpMeSellHouseImageView];
    [_helpMeSellHouseImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(15);
        make.right.equalTo(self.contentView).offset(-15);
        make.height.mas_equalTo(imageHeight);
        make.top.bottom.equalTo(self.contentView);
    }];
    WeakSelf;
    self.didClickCellBlk = ^{
        [wself jumpToOwnerSellHouse];
    };
}


-(void)jumpToOwnerSellHouse {
    NSDictionary *dict = @{}.mutableCopy;
    NSURL *openUrl = [NSURL URLWithString:@"sslocal://house_sale_input"];
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    [[TTRoute sharedRoute] openURLByViewController:openUrl userInfo:userInfo];
}


@end

@implementation FHDetailNeighborhoodOwnerSellHouseModel


@end
