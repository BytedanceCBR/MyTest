//
//  FHDynamicLynxCell.m
//  AKCommentPlugin
//
//  Created by wangxinyu on 2020/9/8.
//

#import "FHDynamicLynxCell.h"
#import "Masonry.h"
#import "FHLynxView.h"
#import "FHLynxRealtorBridge.h"
#import "FHLynxManager.h"
#import "FHSearchHouseModel.h"

static const CGFloat kDefaultCellHeight = 93.0;

@interface FHDynamicLynxCell ()

@property (nonatomic, strong) FHLynxView *lynxView;
@property (nonatomic, strong) FHDynamicLynxModel *cellModel;

@end

@implementation FHDynamicLynxCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    return self;
}

- (void)initUI {
    [self setupLynxView];
    
    [self.lynxView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
}

- (void)setupLynxView {
    self.lynxView = [[FHLynxView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, kDefaultCellHeight)];
    [self.contentView addSubview:self.lynxView];
    FHLynxViewBaseParams *baesparmas = [[FHLynxViewBaseParams alloc] init];
    baesparmas.channel = @"lynx_house_find_card";
    baesparmas.bridgePrivate = self;
    baesparmas.clsPrivate = [FHLynxRealtorBridge class];
    [self.lynxView loadLynxWithParams:baesparmas];
}

- (void)refreshWithData:(id)data {
    self.cellModel = (FHDynamicLynxModel *)data;
    FHDynamicLynxLynxDataModel *lynxModel = self.cellModel.lynxData;
    if (lynxModel && self.lynxView) {
        [self.lynxView updateData:lynxModel.toDictionary];
    }
}

+ (CGFloat)heightForData:(id)data {
    FHDynamicLynxModel *model = (FHDynamicLynxModel *)data;
    if (model && [model isKindOfClass:[FHDynamicLynxModel class]]) {
        return [model.height floatValue];
    }
    
    return kDefaultCellHeight;
}

@end
