//
//  FHDetailOldEvaluateCell.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/5/21.
//

#import "FHDetailOldEvaluateCell.h"
#import "Masonry.h"
#import "UIFont+House.h"
#import <UIImageView+BDWebImage.h>
#import "FHCommonDefines.h"
#import "FHDetailOldModel.h"
#import "FHURLSettings.h"
#import "TTRoute.h"
#import "FHDetailHeaderView.h"
#import "FHExtendHotAreaButton.h"
#import "FHDetailFoldViewButton.h"
#import "UILabel+House.h"
#import "FHDetailMultitemCollectionView.h"
#import "FHDetailStarsCountView.h"
#import "FHDetailStarHeaderView.h"
#import "FHUtils.h"

@interface FHDetailOldEvaluateCell ()
@property (nonatomic, strong)   FHDetailStarHeaderView       *headerView;
@property (nonatomic, strong)   UIView       *containerView;
@end

@implementation FHDetailOldEvaluateCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailOldEvaluateModel class]]) {
        return;
    }
    self.currentData = data;
    for (UIView *v in self.containerView.subviews) {
        [v removeFromSuperview];
    }
    //
    FHDetailOldEvaluateModel *model = (FHDetailOldEvaluateModel *)data;
    if (model.evaluationInfo) {
        if (model.evaluationInfo.title.length > 0) {
            [_headerView updateTitle:model.evaluationInfo.title];
        }
        [self.headerView updateStarsCount:[model.evaluationInfo.totalScore integerValue]];
        if (model.evaluationInfo.subScores.count > 0) {
            UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
            flowLayout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20);
            flowLayout.itemSize = CGSizeMake(140, 134);// 实际高度122，有阴影
            flowLayout.minimumLineSpacing = 10;
            flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
            NSString *identifier = NSStringFromClass([FHDetailOldEvaluationItemCollectionCell class]);
            FHDetailMultitemCollectionView *colView = [[FHDetailMultitemCollectionView alloc] initWithFlowLayout:flowLayout viewHeight:134 cellIdentifier:identifier cellCls:[FHDetailOldEvaluationItemCollectionCell class] datas:model.evaluationInfo.subScores];
            [self.containerView addSubview:colView];
            colView.backgroundColor = [UIColor clearColor];
            colView.collectionContainer.backgroundColor = [UIColor clearColor];
            __weak typeof(self) wSelf = self;
            colView.clickBlk = ^(NSInteger index) {
                [wSelf collectionCellClick:index];
            };
            [colView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.containerView).offset(0);
                make.left.right.mas_equalTo(self.containerView);
                make.bottom.mas_equalTo(self.containerView);
            }];
            [colView reloadData];
        } else {
            [self.headerView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.right.mas_equalTo(self.containerView);
                make.top.mas_equalTo(0);
                make.height.mas_equalTo(66);
                make.bottom.mas_equalTo(self.containerView).offset(0);
            }];
        }
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

- (void)setupUI {
    _headerView = [[FHDetailStarHeaderView alloc] init];
    [_headerView updateTitle:@"小区评测"];
    [self.contentView addSubview:_headerView];
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(self.contentView);
        make.height.mas_equalTo(110);
    }];
    [self.headerView addTarget:self action:@selector(moreButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    _containerView = [[UIView alloc] init];
    _containerView.clipsToBounds = YES;
    _containerView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_containerView];
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(60);
        make.left.right.mas_equalTo(self.contentView);
        make.bottom.mas_equalTo(self.contentView).offset(-24);
    }];
}

// 查看更多
- (void)moreButtonClick:(UIButton *)button {
    FHDetailOldEvaluateModel *model = (FHDetailOldEvaluateModel *)self.currentData;
    if (model.evaluationInfo.detailUrl.length > 0) {
        [self gotoDetail];
    }
}
// cell 点击
- (void)collectionCellClick:(NSInteger)index {
    FHDetailOldEvaluateModel *model = (FHDetailOldEvaluateModel *)self.currentData;
    if (model.evaluationInfo && model.evaluationInfo.subScores.count > 0 && index >= 0 && index < model.evaluationInfo.subScores.count) {
        // 点击cell处理
        FHDetailNeighborhoodNeighborhoodInfoEvaluationInfoSubScoresModel *itemModel = model.evaluationInfo.subScores[index];
        [self gotoDetail];
    }
}

- (NSString *)getEvaluateWebParams:(NSDictionary *)dic {
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONReadingAllowFragments error:&error];
    if (data && !error) {
        NSString *temp = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        temp = [temp stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
        return temp;
    }
    return nil;
}

- (void)gotoDetail {
    FHDetailOldEvaluateModel *model = (FHDetailOldEvaluateModel *)self.currentData;
    if (model.evaluationInfo.detailUrl.length > 0) {
        NSString *enter_from = @"neighborhood_detail";
        NSString *urlStr = model.evaluationInfo.detailUrl;// @"http://10.1.15.29:8889/f100/client/xiaoqu/evaluate?neighborhood_id=6581420533487763726";
        if (urlStr.length > 0) {
            NSMutableDictionary *tracerDic = [NSMutableDictionary new];
            NSDictionary *temp = [self.baseViewModel.detailTracerDic dictionaryWithValuesForKeys:@[@"origin_from",@"origin_search_id"]];
            [tracerDic addEntriesFromDictionary:temp];
            tracerDic[@"enter_from"] = enter_from;
            tracerDic[@"log_pb"] = model.log_pb ? model.log_pb : @"be_null";// 特殊，传入当前小区的logpb
            [FHUserTracker writeEvent:@"enter_neighborhood_evaluation" params:tracerDic];
            //
            NSString *reportParams = [self getEvaluateWebParams:tracerDic];
            NSString *jumpUrl = @"sslocal://webview";
            NSString *openUrl = [NSString stringWithFormat:@"%@&report_params=%@",urlStr,reportParams];
            
            TTRouteUserInfo *info = [[TTRouteUserInfo alloc] initWithInfo:@{@"title":@"小区评测",@"url":openUrl}];
            [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:jumpUrl] userInfo:info];
        }
    }
}

- (NSString *)elementTypeString:(FHHouseType)houseType {
    return @"neighborhood_evaluation";
}

@end


@interface FHDetailOldEvaluationItemCollectionCell ()

@end

@implementation FHDetailOldEvaluationItemCollectionCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self setupUI];
    }
    return self;
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailNeighborhoodNeighborhoodInfoEvaluationInfoSubScoresModel class]]) {
        return;
    }
    self.currentData = data;
    FHDetailNeighborhoodNeighborhoodInfoEvaluationInfoSubScoresModel *model = (FHDetailNeighborhoodNeighborhoodInfoEvaluationInfoSubScoresModel *)data;
    if (model) {
        [self layoutDescLabelForText:model.content.length > 0  ? model.content : @"暂无信息"];
        self.nameLabel.text = model.scoreName;
        CGFloat scoreValue = [model.scoreValue floatValue];
        self.scoreLabel.text = [NSString stringWithFormat:@"%.1f",scoreValue / 10.0];
        self.levelLabel.text = model.scoreLevel;
        NSInteger levelV = [model.scoreLevel integerValue];
        if (levelV == 1) {
            self.levelLabel.backgroundColor = [UIColor themeRed1];
            self.levelLabel.text = @"高";
        } else {
            self.levelLabel.backgroundColor = [UIColor themeGreen1];
            self.levelLabel.text = @"低";
        }
    }
    [self layoutIfNeeded];
}

- (void)setupUI {
    
    _backView = [[UIView alloc] init];
    _backView.layer.cornerRadius = 4.0;
    _backView.backgroundColor = [UIColor whiteColor];
    
    _descLabel = [UILabel createLabel:@"" textColor:@"" fontSize:12];
    _descLabel.textColor = [UIColor themeGray3];
    
    _nameLabel = [UILabel createLabel:@"" textColor:@"" fontSize:16];
    _nameLabel.textColor = [UIColor themeGray1];
    _nameLabel.font = [UIFont themeFontMedium:16];
    _nameLabel.textAlignment = NSTextAlignmentLeft;
    
    _scoreLabel = [UILabel createLabel:@"" textColor:@"" fontSize:14];
    _scoreLabel.textColor = [UIColor themeGray3];
    
    _levelLabel = [UILabel createLabel:@"" textColor:@"#ffffff" fontSize:12];
    _levelLabel.textAlignment = NSTextAlignmentCenter;
    _levelLabel.backgroundColor = [UIColor themeRed1];
    _levelLabel.layer.masksToBounds = YES;
    
    [self.contentView addSubview:_backView];
    
    [_backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.contentView);
        make.height.mas_equalTo(122);
        make.width.mas_equalTo(140);
    }];
    
    [self.backView addSubview:_nameLabel];
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.backView).offset(12);
        make.top.mas_equalTo(self.backView).offset(19);
        make.height.mas_equalTo(22);
        make.width.mas_equalTo(70);
    }];
    
    [self.backView addSubview:_levelLabel];
    [_levelLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.backView);
        make.height.width.mas_equalTo(22);
        make.top.mas_equalTo(self.nameLabel);
    }];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 22, 22) byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft cornerRadii:CGSizeMake(4, 4)];
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.frame  = self.bounds;
    layer.path = path.CGPath;
    self.levelLabel.layer.mask = layer;
    [self.backView addSubview:_scoreLabel];
    [_scoreLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_scoreLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.scoreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.levelLabel.mas_left).offset(-9);
        make.height.mas_equalTo(22);
        make.top.mas_equalTo(self.nameLabel);
    }];

    // 添加阴影
    self.backView.layer.shadowColor = [UIColor blackColor].CGColor;//shadowColor阴影颜色
    self.backView.layer.shadowOffset = CGSizeMake(0, 2);//shadowOffset阴影偏移，默认(0, -3),这个跟shadowRadius配合使用
    self.backView.layer.shadowOpacity = 0.1;//0.8;//阴影透明度，默认0
    self.backView.layer.shadowRadius = 4;//8;//阴影半径，默认3
}

- (void)layoutDescLabelForText:(NSString *)text
{
    [self.descLabel removeFromSuperview];
    CGFloat heightText = [self labelWithHeight:text label:self.descLabel width:120];
    [self.backView addSubview:self.descLabel];
    self.descLabel.frame = CGRectMake(12, 45, 120, heightText > 68 ? 68 : heightText);
    self.descLabel.text = text;
    self.descLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.descLabel.numberOfLines = 4;
}
- (CGFloat)labelWithHeight:(NSString*)labelStr label:(UILabel *)label width:(CGFloat)width {
    NSString *statusLabelText = labelStr;
    CGSize size = CGSizeMake(width, 900);
    NSDictionary *dic = [NSDictionary dictionaryWithObject:label.font forKey:NSFontAttributeName];
    CGSize strSize = [statusLabelText boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    return strSize.height;
}

@end


// FHDetailOldEvaluateModel
@implementation FHDetailOldEvaluateModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _log_pb = nil;
    }
    return self;
}

@end
