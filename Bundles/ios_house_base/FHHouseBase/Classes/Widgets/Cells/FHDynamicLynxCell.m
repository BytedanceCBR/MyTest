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

static const CGFloat kDefaultCellHeight = 83.0;

@interface FHDynamicLynxCell ()

@property (nonatomic, strong) FHLynxView *lynxView;

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
}

- (void)refreshWithData:(id)data {
    if (!data) {
        return;
    }
    
    FHDynamicLynxModel *model = (FHDynamicLynxModel *)data;
    if ([model isKindOfClass:[FHDynamicLynxModel class]]) {
        FHLynxViewBaseParams *baesparmas = [[FHLynxViewBaseParams alloc] init];
        baesparmas.channel = model.channel ?: @"";
        baesparmas.bridgePrivate = self;
        baesparmas.clsPrivate = [FHLynxRealtorBridge class];
        [self.lynxView loadLynxWithParams:baesparmas];
        
        FHDynamicLynxLynxDataModel *lynxModel = model.lynxData;
        if (lynxModel && self.lynxView) {
            [self.lynxView updateData:lynxModel.toDictionary];
        }
    }
}

+ (CGFloat)heightForData:(id)data {
    FHDynamicLynxModel *model = (FHDynamicLynxModel *)data;
    if (model && [model isKindOfClass:[FHDynamicLynxModel class]]) {
        return [model.height floatValue];
    }
    
    return 0;  //未下发数据或者model类型不正确则隐藏cell
}

@end
