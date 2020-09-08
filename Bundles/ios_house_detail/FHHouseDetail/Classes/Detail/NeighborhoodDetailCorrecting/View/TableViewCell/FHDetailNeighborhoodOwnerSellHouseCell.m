//
//  FHDetailNeighborhoodOwnerSellHouseCell.m
//  FHHouseDetail
//
//  Created by bytedance on 2020/9/6.
//

#import "FHDetailNeighborhoodOwnerSellHouseCell.h"
#import "FHCommonDefines.h"
#import "BDWebImageManager.h"

@interface FHDetailNeighborhoodOwnerSellHouseCell ()
@property(nonatomic,strong) UIImageView *helpMeSellHouseImageView;
@property(nonatomic,copy) NSString *helpMeSellHouseOpenUrl;
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

-(void)refreshWithData:(id)data {
    if(self.currentData == data || ![data isKindOfClass:[FHDetailNeighborhoodOwnerSellHouseModel class]]) {
        return;
    }
    self.currentData = data;
    FHDetailNeighborhoodOwnerSellHouseModel *model = (FHDetailNeighborhoodOwnerSellHouseModel *) data;
    if(model.imgUrl.length > 0) {
        WeakSelf;
        [[BDWebImageManager sharedManager] requestImage:[NSURL URLWithString:model.imgUrl] options:BDImageRequestHighPriority complete:^(BDWebImageRequest *request, UIImage *image, NSData *data, NSError *error, BDWebImageResultFrom from) {
            if(!error && image) {
                CGFloat imageHeight = image.size.height * (SCREEN_WIDTH - 30) / image.size.width;
                wself.helpMeSellHouseImageView.image = image;
                [wself.helpMeSellHouseImageView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(imageHeight);
                }];
            }
        }];
    } else {
        UIImage *helpMeSellHouseImage = [UIImage imageNamed:@"helpMeSellHouse"];
        CGFloat imageHeight = helpMeSellHouseImage.size.height * (SCREEN_WIDTH - 30) / helpMeSellHouseImage.size.width;
        self.helpMeSellHouseImageView.image = helpMeSellHouseImage;
        [self.helpMeSellHouseImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(imageHeight);
        }];
    }
}

-(void)setupUI {
    _helpMeSellHouseImageView = [[UIImageView alloc] init];
    [self.contentView addSubview:_helpMeSellHouseImageView];
    [_helpMeSellHouseImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(15);
        make.right.equalTo(self.contentView).offset(-15);
        make.top.equalTo(self.contentView).offset(6);
        make.bottom.equalTo(self.contentView).offset(-6);
    }];
    WeakSelf;
    self.didClickCellBlk = ^{
        [wself jumpToOwnerSellHouse];
    };
}


-(void)jumpToOwnerSellHouse {
    NSMutableDictionary *dict = @{}.mutableCopy;
//    NSURL *openUrl = [NSURL URLWithString:self.helpMeSellHouseOpenUrl];
    NSURL *openUrl = [NSURL URLWithString:@"sslocal://house_sale_input?neighbourhood_id=6697827211568742659&neighbourhood_name=%e8%8a%8d%e8%8d%af%e5%b1%85&report_params=%7b%22enter_from%22%3a%22old_detail%22%2c%22element_from%22%3a%22driving_sale_house%22%7d"];
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    [[TTRoute sharedRoute] openURLByViewController:openUrl userInfo:userInfo];
}


@end

@implementation FHDetailNeighborhoodOwnerSellHouseModel


@end
