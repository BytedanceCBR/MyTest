//
//  FHNeighborhoodDetailQuestionHeaderCell.m
//  FHHouseDetail
//
//  Created by 谢思铭 on 2020/10/13.
//

#import "FHNeighborhoodDetailQuestionHeaderCell.h"
#import <TTRoute.h>
#import "TTBaseMacro.h"
#import "FHUserTracker.h"
#import "UIDevice+BTDAdditions.h"

@interface FHNeighborhoodDetailQuestionHeaderCell ()

@property (nonatomic, strong) UIView *topLine;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *rightBtn;

@end

@implementation FHNeighborhoodDetailQuestionHeaderCell

+ (CGSize)cellSizeWithData:(id)data width:(CGFloat)width {
    if (data && [data isKindOfClass:[FHNeighborhoodDetailQuestionHeaderModel class]]) {
        FHNeighborhoodDetailQuestionHeaderModel *model = (FHNeighborhoodDetailQuestionHeaderModel *)data;
        CGFloat height = model.topMargin + 25 + 7;
        
        return CGSizeMake(width, height);
    }
    return CGSizeZero;
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHNeighborhoodDetailQuestionHeaderModel class]]) {
        return;
    }
    self.currentData = data;
    FHNeighborhoodDetailQuestionHeaderModel *model = (FHNeighborhoodDetailQuestionHeaderModel *)data;
    if (model) {
        self.titleLabel.text = model.title;
        self.topLine.hidden = model.hiddenTopLine;
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
        [self initConstraints];
    }
    return self;
}

- (void)initViews {
    self.topLine = [[UIView alloc] init];
    _topLine.backgroundColor = [UIColor themeGray6];
    [self.contentView addSubview:_topLine];
    
    self.titleLabel = [UILabel createLabel:@"" textColor:@"" fontSize:18];
    _titleLabel.textColor = [UIColor themeGray1];
    _titleLabel.font = [UIFont themeFontMedium:18];
    [self.contentView addSubview:_titleLabel];
    
    self.rightBtn = [[UIButton alloc] init];
    [_rightBtn setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_rightBtn setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    _rightBtn.imageView.contentMode = UIViewContentModeCenter;
    [_rightBtn setImage:[UIImage imageNamed:@"neighborhood_detail_comment_right_arror"] forState:UIControlStateNormal];
    [_rightBtn setTitleColor:[UIColor themeOrange4] forState:UIControlStateNormal];
    _rightBtn.titleLabel.font = [UIFont themeFontRegular:14];
    [_rightBtn setTitle:@"查看全部" forState:UIControlStateNormal];
    [_rightBtn sizeToFit];
    [_rightBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, - _rightBtn.imageView.image.size.width, 0, _rightBtn.imageView.image.size.width)];
    [_rightBtn setImageEdgeInsets:UIEdgeInsetsMake(0, _rightBtn.titleLabel.bounds.size.width, 0, -_rightBtn.titleLabel.bounds.size.width)];
    [_rightBtn addTarget:self action:@selector(gotoQuestionList) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_rightBtn];
}

- (void)initConstraints {
    [self.topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView);
        make.left.mas_equalTo(self.contentView).offset(16);
        make.right.mas_equalTo(self.contentView).offset(-16);
        make.height.mas_equalTo([UIDevice btd_onePixel]);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.contentView).offset(-7);
        make.left.mas_equalTo(self.contentView).offset(16);
        make.right.mas_equalTo(self.rightBtn.mas_left).offset(-5);
        make.height.mas_equalTo(25);
    }];
    
    [self.rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.titleLabel);
        make.right.mas_equalTo(self.contentView).offset(-16);
        make.height.mas_equalTo(25);
    }];
}

- (void)gotoQuestionList {
    FHNeighborhoodDetailQuestionHeaderModel *cellModel = (FHNeighborhoodDetailQuestionHeaderModel *)self.currentData;
    if(!isEmptyString(cellModel.questionListSchema)){
        NSURL *url = [NSURL URLWithString:cellModel.questionListSchema];
        NSMutableDictionary *dict = @{}.mutableCopy;
        dict[@"neighborhood_id"] = cellModel.neighborhoodId;
        dict[@"title"] = cellModel.title;
//        NSMutableDictionary *tracerDict = @{}.mutableCopy;
//        tracerDict[UT_ORIGIN_FROM] = cellModel.tracerDict[@"origin_from"] ?: @"be_null";
//        tracerDict[UT_ENTER_FROM] = cellModel.tracerDict[@"page_type"] ?: @"be_null";
//        tracerDict[UT_ELEMENT_FROM] = @"";
//        tracerDict[UT_LOG_PB] = cellModel.tracerDict[@"log_pb"] ?: @"be_null";
//        tracerDict[@"from_gid"] = self.baseViewModel.houseId;
//        dict[TRACER_KEY] = tracerDict;
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    }
}

@end

@implementation FHNeighborhoodDetailQuestionHeaderModel


@end
