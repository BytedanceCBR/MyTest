//
//  FHDetailDetectiveCell.m
//  FHHouseDetail
//
//  Created by 张静 on 2019/7/2.
//

#import "FHDetailDetectiveCell.h"
#import "FHDetectiveTopView.h"
#import "FHDetectiveContainerView.h"
#import <FHCommonUI/FHRoundShadowView.h>
#import "Masonry.h"
#import "FHDetailOldModel.h"
#import <TTRoute/TTRoute.h>
#import "FHDetectiveItemView.h"
#import "FHDetailHalfPopFooter.h"

extern NSString *const DETAIL_SHOW_POP_LAYER_NOTIFICATION ;

@interface FHDetailDetectiveCell ()

@property (nonatomic, strong) FHDetectiveTopView *topView;
@property (nonatomic, strong) FHDetectiveContainerView *containerView;
@property (nonatomic, strong) UIView *detectiveView;
@property(nonatomic , strong) FHDetailHalfPopFooter *footer;
@property (nonatomic, strong) FHRoundShadowView *shadowView;
@property (nonatomic, assign) BOOL showPriceCause;

@end

@implementation FHDetailDetectiveCell

- (void)refreshWithData:(id)data
{
    if (self.currentData == data || ![data isKindOfClass:[FHDetailDetectiveModel class]]) {
        return;
    }
    self.currentData = data;
    FHDetailDetectiveModel *model = (FHDetailDetectiveModel *)data;
    [self.topView updateWithTitle:model.detective.dialogs.title tip:model.detective.dialogs.subTitle];

    if (model.detective.detectiveInfo.detectiveList.count > 0) {
        
        for (UIView *subview in self.detectiveView.subviews) {
            [subview removeFromSuperview];
        }
        UIView *lastView = nil;
        NSArray *detectiveList = model.detective.detectiveInfo.detectiveList;
        __weak typeof(self)wself = self;
        for (NSInteger index = 0; index < detectiveList.count; index++) {
            FHDetailDataBaseExtraDetectiveDetectiveInfoDetectiveListModel *item = detectiveList[index];
            if (item.reasonInfo) {
                self.showPriceCause = YES;
            }
            FHDetectiveItemView *itemView = [[FHDetectiveItemView alloc]initWithFrame:CGRectZero];
            itemView.actionBlock = ^(id reasonInfoData) {
                [wself showReasonInfoView:reasonInfoData];
            };
            [itemView updateWithModel:item];
            [self.detectiveView addSubview:itemView];
            CGFloat height = [FHDetectiveItemView heightForTile:item.title tip:item.explainContent];
            height = MAX(height, 40 + 17 + 4) + 30;
            [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
                if (lastView) {
                    make.top.mas_equalTo(lastView.mas_bottom);
                }else {
                    make.top.mas_equalTo(5);
                }
                if (index == detectiveList.count - 1) {
                    make.bottom.mas_equalTo(-5);
                }
                make.left.right.mas_equalTo(0);
                make.height.mas_equalTo(height);
            }];
            lastView = itemView;
            [itemView showBottomLine:(index != detectiveList.count - 1)];
        }
    }
    [_footer showTip:model.detective.dialogs.feedbackContent type:FHDetailHalfPopFooterTypeChoose positiveTitle:@"是" negativeTitle:@"否"];
}

- (void)showReasonInfoView:(id)reasonInfoData
{
    [[NSNotificationCenter defaultCenter] postNotificationName:DETAIL_SHOW_POP_LAYER_NOTIFICATION object:nil userInfo:@{@"cell":self,@"model":reasonInfoData?:@""}];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (NSArray *)elementTypeStringArray:(FHHouseType)houseType
{
    NSMutableArray *array = @[@"happiness_eye_detail"].mutableCopy;
    if (self.showPriceCause) {
        [array addObject:@"low_price_cause"];
    }
    return array;
}

- (void)setupUI {

    [self.contentView addSubview:self.topView];
    [self.contentView addSubview:self.shadowView];
    [self.contentView addSubview:self.containerView];
    [self.containerView addSubview:self.detectiveView];
    [self.containerView addSubview:self.footer];

    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
    }];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(65 + 22);
        make.bottom.mas_equalTo(-20);
    }];
    [self.shadowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.containerView);
    }];
    [self.detectiveView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
    }];
    [self.footer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.detectiveView.mas_bottom);
        make.bottom.mas_equalTo(0);
        make.left.mas_equalTo(-5);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(60);
    }];
    
    __weak typeof(self)wself = self;
    self.topView.tapBlock = ^{
        [wself jump2Report];
    };
    
    self.footer.actionBlock = ^(NSInteger positive) {
        [wself feedBack:positive];
    };
}

- (void)feedBack:(NSInteger)type
{
    FHDetailDetectiveModel *model = (FHDetailDetectiveModel *)self.currentData;
    model.detective.fromDetail = YES;
    if (model.feedBack) {
        __weak typeof(self) wself = self;
        self.footer.actionButton.enabled = NO;
        self.footer.negativeButton.enabled = NO;
        model.feedBack(type, model.detective, ^(BOOL success) {
            [wself updateFooterFeedback:success];
        });
        [wself addClickAgreeLogType:type];
    }
}

- (void)updateFooterFeedback:(BOOL)success
{
    if (success) {
        [self.footer changeToFeedbacked];
    }else{
        self.footer.actionButton.enabled = YES;
        self.footer.negativeButton.enabled = YES;
    }
}

- (void)jump2Report
{
    FHDetailDetectiveModel *model = (FHDetailDetectiveModel *)self.currentData;
    model.detective.fromDetail = YES;
    [self.baseViewModel popLayerReport:model.detective];
}

#pragma mark - log
-(void)addClickAgreeLogType:(NSInteger)type
{
    NSMutableDictionary *param = [NSMutableDictionary new];
    param[@"page_type"] = self.baseViewModel.detailTracerDic[@"page_type"] ? : @"be_null";
    param[@"enter_from"] = @"happiness_eye_detail";
    param[@"element_from"] = self.baseViewModel.detailTracerDic[@"element_from"] ? : @"be_null";
    param[@"origin_from"] = self.baseViewModel.detailTracerDic[@"origin_from"] ? : @"be_null";
    param[@"origin_search_id"] = self.baseViewModel.detailTracerDic[@"origin_search_id"] ? : @"be_null";
    param[@"log_pb"] = self.baseViewModel.detailTracerDic[@"log_pb"] ? : @"be_null";
    param[@"rank"] = self.baseViewModel.detailTracerDic[@"rank"] ? : @"be_null";
    param[@"click_position"] = (type == 1)?@"yes":@"no";
    
    TRACK_EVENT(@"click_agree", param);
}

- (FHDetectiveTopView *)topView
{
    if (!_topView) {
        _topView = [[FHDetectiveTopView alloc]init];
    }
    return _topView;
}

- (FHDetectiveContainerView *)containerView
{
    if (!_containerView) {
        _containerView = [[FHDetectiveContainerView alloc]init];
        _containerView.layer.cornerRadius = 4;
        _containerView.layer.masksToBounds = YES;
    }
    return _containerView;
}

- (UIView *)detectiveView
{
    if (!_detectiveView) {
        _detectiveView = [[UIView alloc]init];
    }
    return _detectiveView;
}

- (FHDetailHalfPopFooter *)footer
{
    if (!_footer) {
        _footer = [[FHDetailHalfPopFooter alloc]init];
    }
    return _footer;
}

- (FHRoundShadowView *)shadowView
{
    if (!_shadowView) {
        _shadowView = [[FHRoundShadowView alloc] initWithFrame:CGRectZero];
        _shadowView.cornerRadius = 4;
        _shadowView.shadowOffset = CGSizeMake(2, 4);
        _shadowView.shadowRadius = 6;
        _shadowView.shadowColor = [UIColor blackColor];
        _shadowView.shadowOpacity = 0.1;
    }
    return _shadowView;
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

@implementation FHDetailDetectiveModel

@end
