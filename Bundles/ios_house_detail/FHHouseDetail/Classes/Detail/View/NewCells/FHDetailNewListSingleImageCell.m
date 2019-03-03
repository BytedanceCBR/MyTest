//
//  FHDetailNewListSingleImageCell.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/21.
//

#import "FHDetailNewListSingleImageCell.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import <YYText/YYText.h>
#import "TTDeviceHelper.h"
#import "Masonry.h"
#import "FHHouseSingleImageInfoCellBridgeDelegate.h"
#import "UIImageView+BDWebImage.h"
#import "FHCornerView.h"
#import "FHSingleImageInfoCellModel.h"
#import "FHHomeHouseModel.h"

@interface FHDetailNewListSingleImageCell () <FHHouseSingleImageInfoCellBridgeDelegate>

@property(nonatomic, strong) FHSingleImageInfoCellModel *cellModel;
@property(nonatomic, strong) FHNewHouseItemModel *itemModel;

@property(nonatomic, strong) UIImageView *majorImageView;
@property(nonatomic, strong) UILabel *majorTitle;
@property(nonatomic, strong) UILabel *extendTitle;
@property(nonatomic, strong) YYLabel *areaLabel;
@property(nonatomic, strong) UILabel *priceLabel;
@property(nonatomic, strong) UILabel *originPriceLabel;
@property(nonatomic, strong) UILabel *roomSpaceLabel;

@property(nonatomic, weak) UIView *infoPanel;

@property(nonatomic, strong) UIView *headView;
@property(nonatomic, strong) UIView *bottomView;

@property(nonatomic, strong) UILabel *imageTopLeftLabel;
@property(nonatomic, strong) FHCornerView *imageTopLeftLabelBgView;

@property(nonatomic, assign) CGFloat topMargin;
@property(nonatomic, assign) CGFloat bottomMargin;
@property(nonatomic, assign) BOOL lastShowTag;

@end

@implementation FHDetailNewListSingleImageCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.topMargin = 20;
        self.bottomMargin = 10;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self setupUI];
    }
    return self;
    
}

-(void)setupUI {
    
    [self.contentView addSubview:self.headView];
    [self.headView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.right.top.mas_equalTo(self.contentView);
        make.height.mas_equalTo(@(self.topMargin));
    }];
    
    [self.contentView addSubview:self.bottomView];
    
    [self.contentView addSubview:self.majorImageView];
    [self.majorImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(@20);
        make.top.mas_equalTo(self.headView.mas_bottom);
        make.width.mas_equalTo(@114);
        make.height.mas_equalTo(85);
        
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.majorImageView.mas_bottom);
        make.left.right.bottom.mas_equalTo(self.contentView);
        make.height.mas_equalTo(@(self.bottomMargin));
    }];
    
    UIView *infoPanel = [[UIView alloc]init];
    [self.contentView addSubview:infoPanel];
    self.infoPanel = infoPanel;
    [infoPanel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.majorImageView.mas_right).offset(12);
        make.top.mas_equalTo(self.majorImageView);
        make.bottom.mas_equalTo(self.contentView);
        make.right.mas_equalTo(self.contentView).mas_offset(-15);
    }];
    
    [infoPanel addSubview:self.majorTitle];
    [self.majorTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(infoPanel);
        make.top.mas_equalTo(infoPanel).mas_offset(-3);
        make.height.mas_equalTo(@22);
    }];
    
    [infoPanel addSubview:self.extendTitle];
    [self.extendTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(infoPanel);
        make.top.mas_equalTo(self.majorTitle.mas_bottom).mas_offset(4);
        make.height.mas_equalTo(@17);
    }];
    
    [infoPanel addSubview:self.areaLabel];
    [self.areaLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(infoPanel).mas_offset(-3);
        make.right.mas_equalTo(infoPanel);
        make.top.mas_equalTo(self.extendTitle.mas_bottom).mas_offset(5);
        make.height.mas_equalTo(@15);
    }];
    
    [infoPanel addSubview:self.priceLabel];
    [infoPanel addSubview:self.roomSpaceLabel];
    [infoPanel addSubview:self.originPriceLabel];
    
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(infoPanel);
        make.top.mas_equalTo(self.areaLabel.mas_bottom).mas_offset(5);
        make.height.mas_equalTo(@24);
        make.width.mas_lessThanOrEqualTo(@130);
    }];
    
    [self.originPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.priceLabel.mas_right).mas_offset(6);
        make.height.mas_equalTo(@17);
        make.centerY.mas_equalTo(self.priceLabel);
    }];
    
    [self.roomSpaceLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.roomSpaceLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    [self.roomSpaceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.priceLabel.mas_right).mas_offset(7);
        make.centerY.mas_equalTo(self.priceLabel);
        make.height.mas_equalTo(@17);
    }];
    
    [infoPanel addSubview:self.imageTopLeftLabelBgView];
    [self.imageTopLeftLabelBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.majorImageView);
        make.top.mas_equalTo(self.majorImageView).mas_offset(0);
        make.height.mas_equalTo(@17);
        make.width.mas_equalTo(@48);
    }];
    
    [self.imageTopLeftLabelBgView addSubview:self.imageTopLeftLabel];
    [self.imageTopLeftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(@0);
        make.right.mas_equalTo(@0);
        make.center.mas_equalTo(self.imageTopLeftLabelBgView);
    }];
    
    _lastShowTag = YES;
    
    __weak typeof(self) wSelf = self;
    self.didClickCellBlk = ^{
        FHNewHouseItemModel *theModel = self.itemModel;
        NSMutableDictionary *traceParam = [NSMutableDictionary new];
        traceParam[@"enter_from"] = @"new_detail";
        traceParam[@"log_pb"] = theModel.logPb;
        traceParam[@"origin_from"] = self.baseViewModel.detailTracerDic[@"origin_from"];
        traceParam[@"card_type"] = @"left_pic";
        traceParam[@"rank"] = @(theModel.index);
        traceParam[@"origin_search_id"] = self.baseViewModel.detailTracerDic[@"origin_search_id"];
        traceParam[@"element_from"] = @"related";
        
        NSDictionary *dict = @{@"house_type":@(1),
                               @"tracer": traceParam
                               };
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        
        NSURL *jumpUrl = [NSURL URLWithString:[NSString stringWithFormat:@"sslocal://new_house_detail?court_id=%@",theModel.houseId]];

        if (jumpUrl != nil) {
            [[TTRoute sharedRoute] openURLByPushViewController:jumpUrl userInfo:userInfo];
        }
    };
    
}

-(void)refreshTopMargin:(CGFloat)top {
    
    if (top == self.topMargin) {
        return;
    }
    self.topMargin = top;
    [self.headView mas_updateConstraints:^(MASConstraintMaker *make) {
        
        make.height.mas_equalTo(@(self.topMargin));
    }];
}

- (NSDictionary *)elementHouseShowUpload
{
    NSString *groupId = self.itemModel.groupId;
    if (!groupId) {
        groupId = self.itemModel.id;
    }
    NSDictionary *logpb = self.itemModel.logPb;
    
    return @{@"element_type":@"related",@"search_id":self.itemModel.searchId ? self.itemModel.searchId : @"be_null",@"group_id": groupId.length > 0 ? groupId : @"be_null",@"impr_id":self.itemModel.imprId ? self.itemModel.imprId : @"be_null",@"house_type":@"new",@"log_pb": logpb ? logpb : @"be_null" ,@"rank":@(self.itemModel.index)};
}

-(void)refreshBottomMargin:(CGFloat)bottom {
    
    if (bottom == self.bottomMargin) {
        return;
    }
    self.bottomMargin = bottom;
    [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(@(self.bottomMargin));
    }];
    
}


-(void)updateOriginPriceLabelConstraints:(NSAttributedString *)originPriceAttrStr {
    
    if (originPriceAttrStr.string.length > 0) {
        
        self.originPriceLabel.attributedText = originPriceAttrStr;
        CGFloat offset = [TTDeviceHelper isScreenWidthLarge320] ? 20 : 15;
        self.originPriceLabel.hidden = NO;
        [self.originPriceLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.priceLabel.mas_right).mas_offset(6);
            make.height.mas_equalTo(@17);
            make.centerY.mas_equalTo(self.priceLabel);
        }];
        
        [self.roomSpaceLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.originPriceLabel.mas_right).mas_offset(offset);
            make.centerY.mas_equalTo(self.priceLabel);
            make.height.mas_equalTo(@17);
        }];
        
    }else {
        
        self.originPriceLabel.hidden = YES;
        [self.roomSpaceLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.priceLabel.mas_right).mas_offset(7);
            make.centerY.mas_equalTo(self.priceLabel).mas_offset(1);
            make.height.mas_equalTo(@17);
        }];
    }
    
}

-(void)updateLayoutComponents:(BOOL)isShowTags {
    
    if (_lastShowTag && isShowTags) {
        //没有变更不需要改变
        return;
    }
    _lastShowTag = isShowTags;
    
    CGSize fitSize = self.cellModel.titleSize;
    self.majorTitle.numberOfLines = isShowTags ? 1 : 2;
    
    if (isShowTags) {
        
        [self.majorTitle mas_updateConstraints:^(MASConstraintMaker *make) {
            
            make.top.mas_equalTo(self.infoPanel).mas_offset(-3);
            make.height.mas_equalTo(@22);
        }];
        
    }else {
        
        [self.majorTitle mas_updateConstraints:^(MASConstraintMaker *make) {
            
            make.top.mas_equalTo(self.infoPanel).mas_offset(fitSize.height < 30 ? -3 : -6);
            make.height.mas_equalTo(fitSize.height < 30 ? @22 : @50);
        }];
    }
    
    [self.extendTitle mas_updateConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(self.majorTitle.mas_bottom).mas_offset(fitSize.height < 30 ? 4 : 1);
    }];
    
    [self.areaLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(self.extendTitle.mas_bottom).mas_offset(isShowTags ? 5 : 0);
        make.height.mas_equalTo(isShowTags ? @15 : @0);
    }];
    
    [self.priceLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(self.areaLabel.mas_bottom).mas_offset(isShowTags ? 5 : 0);
    }];
    
}

-(void)prepareForReuse {
    
    [super prepareForReuse];
    
    self.imageTopLeftLabel.text = nil;
    self.imageTopLeftLabelBgView.hidden = YES;
    
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    return YES;
}

#pragma mark 首页

-(void)updateHomeHouseCellModel:(FHHomeHouseDataItemsModel *)commonModel andType:(FHHouseType)houseType
{
    
}

#pragma mark 二手房
- (void)updateWithModel:(FHSearchHouseDataItemsModel *)model isLastCell:(BOOL)isLastCell {
    
}

#pragma mark 新房
-(void)updateWithNewHouseModel:(FHNewHouseItemModel *)model {
    
}

//新房周边新房
// 子类需要重写的方法，根据数据源刷新当前Cell，以及布局
- (void)refreshWithData:(id)data
{
    if([data isKindOfClass:[FHNewHouseItemModel class]])
    {
        self.itemModel = data;
        
        FHNewHouseItemModel *model = (FHNewHouseItemModel *)data;
        self.majorTitle.text = model.displayTitle;
        self.extendTitle.text = model.displayDescription;
        self.areaLabel.attributedText = self.cellModel.tagsAttrStr;
        if (model.tags) {
            NSMutableAttributedString * attributeString =  [[FHSingleImageInfoCellModel new] tagsStringWithTagList:model.tags];
            self.areaLabel.attributedText =  attributeString;
        }
 
        self.priceLabel.text = model.displayPricePerSqm;
        FHSearchHouseDataItemsHouseImageModel *imageModel = model.images.firstObject;
        [self.majorImageView bd_setImageWithURL:[NSURL URLWithString:imageModel.url] placeholder:[UIImage imageNamed: @"default_image"]];
        
        [self updateOriginPriceLabelConstraints:nil];
        [self updateLayoutComponents:self.areaLabel.attributedText.string.length > 0];
        [self refreshTopMargin:10];
    }
}

#pragma mark 二手房
-(void)updateWithSecondHouseModel:(FHSearchHouseDataItemsModel *)model {
    
}

#pragma mark 租房
-(void)updateWithRentHouseModel:(FHHouseRentDataItemsModel *)model {
  
}

#pragma mark 小区
- (void)updateWithNeighborModel:(FHHouseNeighborDataItemsModel *)model {
  
}

-(void)updateWithHouseCellModel:(FHSingleImageInfoCellModel *)cellModel {
    
    BOOL isFirstCell = NO;
    BOOL isLastCell = NO;
    
    _cellModel = cellModel;
    
    switch (cellModel.houseType) {
        case FHHouseTypeNewHouse:
            
            [self updateWithNewHouseModel:cellModel.houseModel];
            break;
        case FHHouseTypeSecondHandHouse:
            [self updateWithSecondHouseModel:cellModel.secondModel];
            break;
        case FHHouseTypeRentHouse:
            [self updateWithRentHouseModel:cellModel.rentModel];
            break;
        case FHHouseTypeNeighborhood:
            [self updateWithNeighborModel:cellModel.neighborModel];
            break;
        default:
            break;
    }
    
    
}

-(UIImageView *)majorImageView {
    
    if (!_majorImageView) {
        
        _majorImageView = [[UIImageView alloc]init];
        _majorImageView.contentMode = UIViewContentModeScaleAspectFill;
        _majorImageView.layer.cornerRadius = 4;
        _majorImageView.clipsToBounds = YES;
        _majorImageView.layer.borderWidth = 0.5;
        _majorImageView.layer.borderColor = [UIColor themeGray6].CGColor;
        
    }
    return _majorImageView;
}

-(UILabel *)majorTitle {
    
    if (!_majorTitle) {
        
        _majorTitle = [[UILabel alloc]init];
        _majorTitle.font = [UIFont themeFontRegular:16];
        _majorTitle.textColor = [UIColor themeBlack];
    }
    return _majorTitle;
}

-(UILabel *)extendTitle {
    
    if (!_extendTitle) {
        
        _extendTitle = [[UILabel alloc]init];
        _extendTitle.font = [UIFont themeFontRegular:12];
        _extendTitle.textColor = [UIColor themeGray2];
    }
    return _extendTitle;
}

-(YYLabel *)areaLabel {
    
    if (!_areaLabel) {
        
        _areaLabel = [[YYLabel alloc]init];
        _areaLabel.numberOfLines = 0;
        _areaLabel.font = [UIFont themeFontRegular:12];
        _areaLabel.textColor = [UIColor themeGray2];
        _areaLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _areaLabel;
}

-(UILabel *)priceLabel {
    
    if (!_priceLabel) {
        
        _priceLabel = [[UILabel alloc]init];
        _priceLabel.font = [UIFont themeFontMedium:14];
        _priceLabel.textColor = [UIColor themeRed];
    }
    return _priceLabel;
}

-(UILabel *)originPriceLabel {
    
    if (!_originPriceLabel) {
        
        _originPriceLabel = [[UILabel alloc]init];
        if ([TTDeviceHelper isScreenWidthLarge320]) {
            
            _originPriceLabel.font = [UIFont themeFontRegular:12];
        }else {
            _originPriceLabel.font = [UIFont themeFontRegular:10];
        }
        _originPriceLabel.textColor = [UIColor themeGray];
        _originPriceLabel.hidden = YES;
    }
    return _originPriceLabel;
}

-(UILabel *)roomSpaceLabel {
    
    if (!_roomSpaceLabel) {
        
        _roomSpaceLabel = [[UILabel alloc]init];
        if ([TTDeviceHelper isScreenWidthLarge320]) {
            
            _roomSpaceLabel.font = [UIFont themeFontRegular:12];
        }else {
            _roomSpaceLabel.font = [UIFont themeFontRegular:10];
        }
        _roomSpaceLabel.textColor = [UIColor themeGray];
    }
    return _roomSpaceLabel;
}

-(UIView *)headView {
    
    if (!_headView) {
        
        _headView = [[UIView alloc]init];
    }
    return _headView;
}

-(UIView *)bottomView {
    
    if (!_bottomView) {
        
        _bottomView = [[UIView alloc]init];
    }
    return _bottomView;
}

-(UILabel *)imageTopLeftLabel {
    
    if (!_imageTopLeftLabel) {
        
        _imageTopLeftLabel = [[UILabel alloc]init];
        _imageTopLeftLabel.text = @"新上";
        _imageTopLeftLabel.textAlignment = NSTextAlignmentCenter;
        _imageTopLeftLabel.font = [UIFont themeFontRegular:10];
        _imageTopLeftLabel.textColor = [UIColor whiteColor];
    }
    return _imageTopLeftLabel;
}

-(FHCornerView *)imageTopLeftLabelBgView {
    
    if (!_imageTopLeftLabelBgView) {
        
        _imageTopLeftLabelBgView = [[FHCornerView alloc]init];
        _imageTopLeftLabelBgView.backgroundColor = [UIColor themeRed];
        _imageTopLeftLabelBgView.hidden = YES;
    }
    return _imageTopLeftLabelBgView;
}

- (NSString *)elementTypeString:(FHHouseType)houseType {
    return @""; // 周边小区
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