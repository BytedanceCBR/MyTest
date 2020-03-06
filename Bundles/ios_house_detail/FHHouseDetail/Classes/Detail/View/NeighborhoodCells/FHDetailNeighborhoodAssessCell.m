//
//  FHDetailNeighborhoodAssessCell.m
//  FHHouseDetail
//
//  Created by 谢思铭 on 2020/3/6.
//

#import "FHDetailNeighborhoodAssessCell.h"
#import "FHDetailNeighborhoodModel.h"
#import "TTDeviceHelper.h"
#import "FHDetailFoldViewButton.h"
#import "PNChart.h"
#import "FHDetailPriceMarkerView.h"
#import "UIView+House.h"
#import <FHHouseBase/FHUserTracker.h>
#import "FHFeedUGCCellModel.h"
#import "FHNeighbourhoodQuestionCell.h"
#import "TTAccountManager.h"
#import "TTStringHelper.h"
#import "FHUGCCellManager.h"
#import "FHCardSliderView.h"

#define cellId @"cellId"

@interface FHDetailNeighborhoodAssessCell () <UITableViewDelegate,UITableViewDataSource>

@property(nonatomic , strong) NSMutableArray *dataList;
@property(nonatomic, strong) UIView *containerView;
@property(nonatomic, weak) UIImageView *shadowImage;
@property(nonatomic , strong) FHCardSliderView *cardSliderView;
@property(nonatomic , strong) FHUGCCellManager *cellManager;

@end

@implementation FHDetailNeighborhoodAssessCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
        [self initConstaints];
    }
    return self;
}

- (void)setupUI {
    [self.shadowImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView);
        make.top.equalTo(self.contentView).offset(-12);
        make.bottom.equalTo(self.contentView).offset(12);
    }];
    _containerView = [[UIView alloc] init];
    _containerView.clipsToBounds = YES;
    [self.contentView addSubview:_containerView];

    NSArray *dataSource = @[@"01",@"02",@"03",@"04",@"05"];
    
    self.cardSliderView = [[FHCardSliderView alloc] initWithFrame:CGRectZero type:FHCardSliderViewTypeHorizontal];
    _cardSliderView.backgroundColor = [UIColor whiteColor];
    [_cardSliderView setCardListData:dataSource];
    [self.containerView addSubview:_cardSliderView];
}

- (UIImageView *)shadowImage {
    if (!_shadowImage) {
        UIImageView *shadowImage = [[UIImageView alloc]init];
        [self.contentView addSubview:shadowImage];
        _shadowImage = shadowImage;
    }
    return  _shadowImage;
}

- (void)initConstaints {

    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.shadowImage).offset(20);
        make.left.right.mas_equalTo(self.contentView);
        make.bottom.mas_equalTo(self.shadowImage).offset(-20);
    }];
    
    [_cardSliderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.containerView);
        make.left.mas_equalTo(self.containerView).offset(15);
        make.right.mas_equalTo(self.containerView).offset(-15);
        make.height.mas_equalTo(300);
        make.bottom.mas_equalTo(self.containerView);
    }];
}

- (void)refreshWithData:(id)data {
//    if (self.currentData == data || ![data isKindOfClass:[FHDetailQACellModel class]]) {
//        return;
//    }
//    self.currentData = data;
//    FHDetailQACellModel *cellModel = (FHDetailQACellModel *)data;
//    self.shadowImage.image = cellModel.shadowImage;
//    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.height.mas_equalTo(cellModel.viewHeight);
//    }];
//    if (cellModel.shdowImageScopeType == FHHouseShdowImageScopeTypeBottomAll) {
//        [self.shadowImage mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.bottom.equalTo(self.contentView);
//        }];
//    }
//    _titleLabel.text = cellModel.title;
//    [_questionBtn setTitle:cellModel.askTitle forState:UIControlStateNormal];
//
//    self.dataList = [[NSMutableArray alloc] init];
//    [_dataList addObjectsFromArray:cellModel.dataList];
//    [self.tableView reloadData];
//
//    if(self.dataList.count > 0){
//        self.questionBtn.hidden = NO;
//    }else{
//        self.questionBtn.hidden = YES;
//    }
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (void)gotoMore {
//    FHDetailQACellModel *cellModel = (FHDetailQACellModel *)self.currentData;
//    if(!isEmptyString(cellModel.questionListSchema)){
//        NSURL *url = [NSURL URLWithString:cellModel.questionListSchema];
//        NSMutableDictionary *dict = @{}.mutableCopy;
//        dict[@"neighborhood_id"] = cellModel.neighborhoodId;
//        dict[@"title"] = cellModel.title;
//        NSMutableDictionary *tracerDict = @{}.mutableCopy;
//        tracerDict[UT_ORIGIN_FROM] = cellModel.tracerDict[@"origin_from"] ?: @"be_null";
//        tracerDict[UT_ENTER_FROM] = cellModel.tracerDict[@"page_type"] ?: @"be_null";
//        tracerDict[UT_ELEMENT_FROM] = [self elementTypeString:FHHouseTypeNeighborhood];
//        tracerDict[UT_LOG_PB] = cellModel.tracerDict[@"log_pb"] ?: @"be_null";
//        dict[TRACER_KEY] = tracerDict;
//        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
//        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
//    }
}

- (NSString *)elementTypeString:(FHHouseType)houseType {
    return @"neigborhood_question";
}

@end
