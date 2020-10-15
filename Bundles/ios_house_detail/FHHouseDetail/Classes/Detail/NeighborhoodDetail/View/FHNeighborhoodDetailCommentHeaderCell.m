//
//  FHNeighborhoodDetailCommentHeaderCell.m
//  FHHouseDetail
//
//  Created by 谢思铭 on 2020/10/12.
//

#import "FHNeighborhoodDetailCommentHeaderCell.h"
#import <TTRoute.h>
#import "TTBaseMacro.h"
#import "FHUserTracker.h"

@interface FHNeighborhoodDetailCommentHeaderCell ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subTitleLabel;
@property (nonatomic, strong) UIButton *rightBtn;

@end

@implementation FHNeighborhoodDetailCommentHeaderCell

+ (CGSize)cellSizeWithData:(id)data width:(CGFloat)width {
    if (data && [data isKindOfClass:[FHNeighborhoodDetailCommentHeaderModel class]]) {
        FHNeighborhoodDetailCommentHeaderModel *model = (FHNeighborhoodDetailCommentHeaderModel *)data;
        CGFloat height = 20 + 25;
        
        if(model.subTitle.length > 0){
            height += 24;
        }
        
        return CGSizeMake(width, height);
    }
    return CGSizeZero;
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHNeighborhoodDetailCommentHeaderModel class]]) {
        return;
    }
    self.currentData = data;
    FHNeighborhoodDetailCommentHeaderModel *model = (FHNeighborhoodDetailCommentHeaderModel *)data;
    if (model) {
        self.titleLabel.text = model.title;
        self.rightBtn.hidden = !(model.totalCount > model.count);
        if(model.subTitle.length > 0){
            self.subTitleLabel.hidden = NO;
            self.subTitleLabel.text = model.subTitle;
        }else{
            self.subTitleLabel.hidden = YES;
        }
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
    self.titleLabel = [UILabel createLabel:@"" textColor:@"" fontSize:18];
    _titleLabel.textColor = [UIColor themeGray1];
    _titleLabel.font = [UIFont themeFontMedium:18];
    [self.contentView addSubview:_titleLabel];
    
    self.subTitleLabel = [UILabel createLabel:@"" textColor:@"" fontSize:12];
    _subTitleLabel.textColor = [UIColor themeGray3];
    _subTitleLabel.font = [UIFont themeFontRegular:12];
    [self.contentView addSubview:_subTitleLabel];
    
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
    [_rightBtn addTarget:self action:@selector(gotoCommentList) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_rightBtn];
}

- (void)initConstraints {
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(20);
        make.left.mas_equalTo(self.contentView).offset(16);
        make.right.mas_equalTo(self.rightBtn.mas_left).offset(-5);
        make.height.mas_equalTo(25);
    }];
    
    [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(4);
        make.left.mas_equalTo(self.contentView).offset(16);
        make.right.mas_equalTo(self.contentView).offset(-16);
        make.height.mas_equalTo(20);
    }];
    
    [self.rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.titleLabel);
        make.right.mas_equalTo(self.contentView).offset(-16);
        make.height.mas_equalTo(25);
    }];
}

- (void)gotoCommentList {
    FHNeighborhoodDetailCommentHeaderModel *cellModel = (FHNeighborhoodDetailCommentHeaderModel *)self.currentData;
    if(!isEmptyString(cellModel.commentsListSchema)){
        NSURL *url = [NSURL URLWithString:cellModel.commentsListSchema];
        NSMutableDictionary *dict = @{}.mutableCopy;
        dict[@"neighborhood_id"] = cellModel.neighborhoodId;
        dict[@"title"] = cellModel.title;
        NSMutableDictionary *tracerDict = @{}.mutableCopy;
        tracerDict[UT_ORIGIN_FROM] = cellModel.detailTracerDic[@"origin_from"] ?: @"be_null";
        tracerDict[UT_ENTER_FROM] = cellModel.detailTracerDic[@"page_type"] ?: @"be_null";
        tracerDict[UT_LOG_PB] = cellModel.detailTracerDic[@"log_pb"] ?: @"be_null";
        tracerDict[@"from_gid"] = cellModel.neighborhoodId;
        dict[TRACER_KEY] = tracerDict;
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    }
}

@end

@implementation FHNeighborhoodDetailCommentHeaderModel


@end
