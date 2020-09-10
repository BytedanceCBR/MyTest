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
    self.helpMeSellHouseOpenUrl = model.helpMeSellHouseOpenUrl;
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
    [self addClickOptionsLog];
    NSMutableDictionary *dict = @{}.mutableCopy;
    dict[@"origin_from"] = self.baseViewModel.detailTracerDic[@"origin_from"];
    NSURL *openUrl = [NSURL URLWithString:self.helpMeSellHouseOpenUrl];
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    [[TTRoute sharedRoute] openURLByViewController:openUrl userInfo:userInfo];
}

//埋点
- (void)addClickOptionsLog {
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"page_type"] = self.baseViewModel.detailTracerDic[@"page_type"] ?: @"be_null";
    params[@"element_type"] = @"driving_sale_house";
    params[@"click_position"] = @"button";
    params[@"event_tracking_id"] = @"107633";
    TRACK_EVENT(@"click_options", params);
}

@end

@implementation FHDetailNeighborhoodOwnerSellHouseModel


@end
