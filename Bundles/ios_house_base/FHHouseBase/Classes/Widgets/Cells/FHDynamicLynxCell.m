//
//  FHDynamicLynxCell.m
//  AKCommentPlugin
//
//  Created by wangxinyu on 2020/9/8.
//

#import "FHDynamicLynxCell.h"
#import "Masonry.h"
#import "LynxView.h"
#import "FHLynxView.h"
#import "FHLynxRealtorBridge.h"
#import "FHLynxManager.h"

static const CGFloat kDefaultCellHeight = 0;

@interface FHDynamicLynxCell ()

@property (nonatomic, strong) FHLynxView *dynamicView;

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
    
    [self.dynamicView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
}

- (void)setupLynxView {
    self.dynamicView = [[FHLynxView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, kDefaultCellHeight)];
    [self.contentView addSubview:self.dynamicView];
}

- (void)updateWithCellModel:(FHDynamicLynxCellModel *)cellModel {
    if (!cellModel) {
        return;
    }
    
    if ([cellModel isKindOfClass:[FHDynamicLynxCellModel class]]) {
        FHDynamicLynxModel *model = cellModel.model;
        if (model && [model isKindOfClass:[FHDynamicLynxModel class]]) {
            FHLynxViewBaseParams *baesparmas = [[FHLynxViewBaseParams alloc] init];
            baesparmas.channel = model.channel ?: @"";
            baesparmas.bridgePrivate = self;
            baesparmas.clsPrivate = [FHLynxRealtorBridge class];
            [self.dynamicView loadLynxWithParams:baesparmas];
            
            NSDictionary *lynxData = model.lynxData;
            if (lynxData && self.dynamicView) {
                [self.dynamicView updateData:lynxData];
            }
        }
    }
}

+ (CGFloat)heightForData:(id)data {
    if (data && [data isKindOfClass:[FHDynamicLynxCellModel class]]) {
        FHDynamicLynxCellModel *model = (FHDynamicLynxCellModel *)data;
        if (model && [model.cell isKindOfClass:[FHDynamicLynxCell class]]) {
            LynxView *lynxView = ((FHDynamicLynxCell *)model.cell).dynamicView.lynxView;
            if (lynxView) {
                CGFloat height = lynxView.frame.size.height;
                return height;
            }
        }
    }
    
    return 0;  //未下发数据或者model类型不正确则隐藏cell
}

@end
