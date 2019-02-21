//
//  FHDetailRentHouseOutlineInfoCell.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/18.
//

#import "FHDetailRentHouseOutlineInfoCell.h"
#import "FHDetailHouseOutlineInfoCell.h"
#import <Masonry.h>
#import "UIFont+House.h"
#import <UIImageView+BDWebImage.h>
#import "FHCommonDefines.h"
#import "FHDetailOldModel.h"
#import "FHURLSettings.h"
#import "TTRoute.h"
#import "FHDetailHeaderView.h"
#import "FHExtendHotAreaButton.h"
#import "UILabel+House.h"

@interface FHDetailRentHouseOutlineInfoCell ()

@property (nonatomic, strong)   FHDetailHeaderView       *headerView;
@property (nonatomic, strong)   UIView       *containerView;

@property (nonatomic, strong)   UIButton       *infoButton;

@end

@implementation FHDetailRentHouseOutlineInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailRentHouseOutlineInfoModel class]]) {
        return;
    }
    self.currentData = data;
    //
    for (UIView *v in self.containerView.subviews) {
        [v removeFromSuperview];
    }
    FHDetailRentHouseOutlineInfoModel *model = (FHDetailRentHouseOutlineInfoModel *)data;
    __block UIView *lastView = self.containerView;
    if (model.houseOverreview.list.count > 0) {
        NSInteger count = model.houseOverreview.list.count;
        [model.houseOverreview.list enumerateObjectsUsingBlock:^(FHRentDetailResponseDataHouseOverviewListDataModel*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            FHDetailHouseOutlineInfoView *outlineView = [[FHDetailHouseOutlineInfoView alloc] init];
            outlineView.keyLabel.text = obj.title;
            outlineView.valueLabel.text = obj.content;
            [outlineView.valueLabel sizeToFit];
            [outlineView showIconAndTitle:obj.title.length > 0];
            [self.containerView addSubview:outlineView];
            [outlineView mas_makeConstraints:^(MASConstraintMaker *make) {
                if (idx == 0) {
                    make.top.mas_equalTo(0);
                } else {
                    make.top.mas_equalTo(lastView.mas_bottom);
                }
                make.left.right.mas_equalTo(self.containerView);
                if (idx == count - 1) {
                    make.bottom.mas_equalTo(self.containerView);
                }
            }];
            lastView = outlineView;
        }];
    }
    [self layoutIfNeeded];
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (NSString *)elementTypeString:(FHHouseType)houseType {
    return @"house_info";
}

- (void)setupUI {
    _headerView = [[FHDetailHeaderView alloc] init];
    _headerView.label.text = @"房源概况";
    [self.contentView addSubview:_headerView];
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(self.contentView);
        make.height.mas_equalTo(52);// 46 + 6
    }];
    // infoButton
    _infoButton = [[UIButton alloc] init];
    [_infoButton setImage:[UIImage imageNamed:@"info-outline-material"] forState:UIControlStateNormal];
    [_infoButton setTitle:@"举报" forState:UIControlStateNormal];
    NSAttributedString *attriStr = [[NSAttributedString alloc] initWithString:@"举报" attributes:@{
                                                                                                 NSFontAttributeName:[UIFont themeFontRegular:12],
                                                                                                 NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#299cff"]
                                                                                                 }];
    [_infoButton setAttributedTitle:attriStr forState:UIControlStateNormal];
    _infoButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, -5);
    [self.headerView addSubview:_infoButton];
    
    [_infoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.headerView.label);
        make.right.mas_equalTo(self.headerView).offset(-25);
    }];
    
    [self.infoButton addTarget:self action:@selector(feedBackButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    _containerView = [[UIView alloc] init];
    _containerView.clipsToBounds = YES;
    _containerView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:_containerView];
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.headerView.mas_bottom);
        make.left.right.mas_equalTo(self.contentView);
        make.bottom.mas_equalTo(self.contentView).offset(-10);
    }];
}

- (void)feedBackButtonClick:(UIButton *)button {
    // 租房
    FHDetailRentHouseOutlineInfoModel *model = (FHDetailRentHouseOutlineInfoModel *)self.currentData;
    FHRentDetailResponseModel *rentData = (FHRentDetailResponseModel *)model.baseViewModel.detailData;
    NSDictionary *jsonDic = [rentData toDictionary];
    if (model && model.houseOverreview.reportUrl.length > 0 && jsonDic) {
        // 记得添加埋点 add by zyk
        NSString *openUrl = @"sslocal://webview";
        NSDictionary *pageData = @{@"data":jsonDic};
        NSDictionary *commonParams = @{};// 记得修改此处的数据 add by zyk
        NSDictionary *commonParamsData = @{@"data":commonParams};
        NSDictionary *jsParams = @{@"requestPageData":pageData,
                                   @"getNetCommonParams":commonParamsData
                                   };
        NSString * host = [FHURLSettings baseURL] ?: @"https://i.haoduofangs.com";
        NSString *urlStr = [NSString stringWithFormat:@"%@%@",host,model.houseOverreview.reportUrl];
        NSDictionary *info = @{@"url":urlStr,@"fhJSParams":jsParams,@"title":@"房源问题反馈"};
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:info];
        [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:openUrl] userInfo:userInfo];
    }
}


@end


// FHDetailRentHouseOutlineInfoModel
@implementation FHDetailRentHouseOutlineInfoModel


@end
