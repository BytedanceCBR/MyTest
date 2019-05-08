//
//  FHDetailNeighborhoodEvaluateCell.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/20.
//

#import "FHDetailNeighborhoodEvaluateCell.h"
#import <Masonry.h>
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

@interface FHDetailNeighborhoodEvaluateCell ()
@property (nonatomic, strong)   FHDetailHeaderView       *headerView;
@property (nonatomic, strong)   UIView       *containerView;
@property (nonatomic, strong)   FHDetailStarsCountView       *starsContainer;
@end

@implementation FHDetailNeighborhoodEvaluateCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailNeighborhoodEvaluateModel class]]) {
        return;
    }
    self.currentData = data;
    for (UIView *v in self.containerView.subviews) {
        [v removeFromSuperview];
    }
    //
    FHDetailNeighborhoodEvaluateModel *model = (FHDetailNeighborhoodEvaluateModel *)data;
    if (model.evaluationInfo) {
        // starsContainer
        self.starsContainer = [[FHDetailStarsCountView alloc] init];
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoDetail)];
        [self.starsContainer addGestureRecognizer:tapGes];
        [self.containerView addSubview:_starsContainer];
        [_starsContainer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(self.containerView);
            make.top.mas_equalTo(10);
            make.height.mas_equalTo(50);
        }];
        [self.starsContainer updateStarsCount:[model.evaluationInfo.totalScore integerValue]];
        if (model.evaluationInfo.subScores.count > 0) {
            UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
            flowLayout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20);
            flowLayout.itemSize = CGSizeMake(140, 122);
            flowLayout.minimumLineSpacing = 10;
            flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
            NSString *identifier = NSStringFromClass([FHDetailEvaluationItemCollectionCell class]);
            FHDetailMultitemCollectionView *colView = [[FHDetailMultitemCollectionView alloc] initWithFlowLayout:flowLayout viewHeight:122 cellIdentifier:identifier cellCls:[FHDetailEvaluationItemCollectionCell class] datas:model.evaluationInfo.subScores];
            [self.containerView addSubview:colView];
            __weak typeof(self) wSelf = self;
            colView.clickBlk = ^(NSInteger index) {
                [wSelf collectionCellClick:index];
            };
            [colView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.starsContainer.mas_bottom).offset(8);
                make.left.right.mas_equalTo(self.containerView);
                make.bottom.mas_equalTo(self.containerView);
            }];
            [colView reloadData];
        } else {
            [_starsContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.right.mas_equalTo(self.containerView);
                make.top.mas_equalTo(10);
                make.height.mas_equalTo(50);
                make.bottom.mas_equalTo(self.containerView).offset(6);
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
    _headerView = [[FHDetailHeaderView alloc] init];
    _headerView.label.text = @"小区评测";
    _headerView.isShowLoadMore = YES;
    [self.contentView addSubview:_headerView];
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(self.contentView);
        make.height.mas_equalTo(46);
    }];
    [self.headerView addTarget:self action:@selector(moreButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    _containerView = [[UIView alloc] init];
    _containerView.clipsToBounds = YES;
    _containerView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:_containerView];
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.headerView.mas_bottom);
        make.left.right.mas_equalTo(self.contentView);
        make.bottom.mas_equalTo(self.contentView).offset(-20);
    }];
}

// 查看更多
- (void)moreButtonClick:(UIButton *)button {
    FHDetailNeighborhoodEvaluateModel *model = (FHDetailNeighborhoodEvaluateModel *)self.currentData;
    if (model.evaluationInfo.detailUrl.length > 0) {
        [self gotoDetail];
    }
}
// cell 点击
- (void)collectionCellClick:(NSInteger)index {
    FHDetailNeighborhoodEvaluateModel *model = (FHDetailNeighborhoodEvaluateModel *)self.currentData;
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
    FHDetailNeighborhoodEvaluateModel *model = (FHDetailNeighborhoodEvaluateModel *)self.currentData;
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


@interface FHDetailEvaluationItemCollectionCell ()

@end

@implementation FHDetailEvaluationItemCollectionCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 4.0;
        self.backgroundColor = [UIColor whiteColor];
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
    _backView.layer.masksToBounds = YES;
    _backView.backgroundColor = [UIColor themeGray8];
    
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


// FHDetailNeighborhoodEvaluateModel
@implementation FHDetailNeighborhoodEvaluateModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _log_pb = nil;
    }
    return self;
}

@end
