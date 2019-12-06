//
// Created by zhulijun on 2019-06-24.
//

#import "FHODetailCommunityEntryCorrectingCell.h"
#import "BDWebImage.h"
#import "NSTimer+NoRetain.h"
#import "TTBaseMacro.h"
#import "IMConsDefine.h"
#import "FHCommunityUCGBubble.h"
#import <FHHouseBase/UIImage+FIconFont.h>
#import "FHUIAdaptation.h"

@interface FHODetailCommunityEntryCorrectingCell () <FHDetailVCViewLifeCycleProtocol>
@property(nonatomic, weak) UILabel *activeCountInfoLabel;
@property (nonatomic, weak) UIImageView *shadowImage;
@property(nonatomic, strong) FHCommunityUCGBubble *curBubble;
@property(nonatomic, strong) FHCommunityUCGBubble *flowBubble;
@property(nonatomic, weak) UIImageView *arrowView;
@property(nonatomic, weak) UIView *backView;
@property(nonatomic, strong) NSTimer *wheelTimer;
@property(nonatomic) NSUInteger curWheelIndex;
@end

@implementation FHODetailCommunityEntryCorrectingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    [self initViews];
}

- (UIImageView *)shadowImage {
    if (!_shadowImage) {
        UIImageView *shadowImage = [[UIImageView alloc]init];
        [self.contentView addSubview:shadowImage];
        _shadowImage = shadowImage;
    }
    return  _shadowImage;
}

- (UIView *)backView {
    if (!_backView) {
        UIView *backView = [[UIView alloc] init];
        backView.backgroundColor =[UIColor colorWithHexStr:@"#fffaf0"];
        backView.clipsToBounds = YES;
        [self.contentView addSubview:backView];
        _backView = backView;
    }
    return _backView;
}

- (UILabel *)activeCountInfoLabel {
    if (!_activeCountInfoLabel) {
        UILabel *activeCountInfoLabel = [[UILabel alloc] init];
        [activeCountInfoLabel setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        activeCountInfoLabel.font = [UIFont systemFontOfSize:14.0f];
        activeCountInfoLabel.numberOfLines = 1;
        activeCountInfoLabel.textAlignment = NSTextAlignmentLeft;
        [self.backView addSubview:activeCountInfoLabel];
        _activeCountInfoLabel = activeCountInfoLabel;
    }
    return _activeCountInfoLabel;
}

- (UIImageView *)arrowView {
    if (!_arrowView) {
        UIImageView *arrowView = [[UIImageView alloc] init];
        arrowView.image = ICON_FONT_IMG(12, @"\U0000e670", [UIColor colorWithHexStr:@"#895A34"]);//@"detail_red_arrow_right"
        [self.backView addSubview:arrowView];
        _arrowView = arrowView;
    }
    return _arrowView;
}

- (void)initViews {
    [self.shadowImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView);
        make.top.equalTo(self.contentView).offset(-12);
        make.bottom.equalTo(self.contentView).offset(12);
    }];
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).offset(15);
        make.right.mas_equalTo(self.contentView).offset(-15);
        make.top.mas_equalTo(self.shadowImage).offset(22);
        make.bottom.equalTo(self.shadowImage).offset(-32);
    }];
    [self.activeCountInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.backView).offset(16);
        make.top.mas_equalTo(self.backView).offset(18);
        make.centerY.equalTo(self.backView);
    }];
    [self.arrowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.backView).offset(-11);
        make.centerY.equalTo(self.backView);
        make.size.mas_offset(CGSizeMake(12, 12));
    }];
    
    _curBubble = [[FHCommunityUCGBubble alloc] initWithFrame:CGRectMake(_backView.frame.size.width - 22 - 160, 14, 160, 26)];
    _curBubble.bacColor =  [UIColor colorWithHexStr:@"#FEF5E1"];
    _curBubble.cornerRadius = 13;
    _flowBubble = [[FHCommunityUCGBubble alloc] initWithFrame:CGRectMake(_backView.frame.size.width - 22 - 160, 50, 160, 26)];
    _flowBubble.bacColor =  [UIColor colorWithHexStr:@"#FEF5E1"];
    _flowBubble.cornerRadius = 13;
    

    
    [_backView addSubview:_curBubble];
    [_backView addSubview:_flowBubble];
    [self.contentView addSubview:_backView];
    

    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellClick)];
    [_backView addGestureRecognizer:singleTap];
}

- (void)cellClick {
    if (![self.currentData isKindOfClass:[FHDetailCommunityEntryModel class]]) {
        return;
    }
    FHDetailCommunityEntryModel *entryModel = self.currentData;
    if (isEmptyString(entryModel.socialGroupSchema)) {
        return;
    }
    
    NSMutableDictionary *tracerDict = [NSMutableDictionary dictionary];
    if(entryModel.houseType == FHHouseTypeNeighborhood){
        tracerDict[@"enter_from"] = @"neighborhood_detail";
    }
    
    if(entryModel.houseType == FHHouseTypeSecondHandHouse){
        tracerDict[@"enter_from"] = @"old_detail";
    }
    
    tracerDict[@"enter_type"] = @"click";
    tracerDict[@"log_pb"] = entryModel.logPb;
    NSDictionary *dict = @{@"tracer":tracerDict};
    
    TTRouteUserInfo* userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    NSURL *openURL = [NSURL URLWithString:[entryModel.socialGroupSchema stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    if ([[TTRoute sharedRoute] canOpenURL:openURL]) {
        [[TTRoute sharedRoute] openURLByPushViewController:openURL userInfo:userInfo];
    }
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailCommunityEntryModel class]]) {
        return;
    }
    self.currentData = data;
    self.curWheelIndex = 0;
    
    FHDetailCommunityEntryModel *entryModel = data;
    self.shadowImage.image = entryModel.shadowImage;
    if(entryModel.shdowImageScopeType == FHHouseShdowImageScopeTypeBottomAll){
        [self.shadowImage mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.contentView);
        }];
    }
    if(entryModel.shdowImageScopeType == FHHouseShdowImageScopeTypeTopAll){
        [self.shadowImage mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView);
        }];
    }
    if(entryModel.shdowImageScopeType == FHHouseShdowImageScopeTypeAll){
        [self.shadowImage mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.contentView);
        }];
    }
    if (!entryModel.activeInfo) {
        return;
    }
    
    NSInteger numValue = [entryModel.activeCountInfo.count integerValue];
    NSString *numStr = [NSString stringWithFormat:@"%ld", numValue];
    NSString *textStr = [NSString stringWithFormat:@" %@", entryModel.activeCountInfo.text];
    NSString *combineStr = [NSString stringWithFormat:@"%@%@", numStr, textStr];
    if (numValue < 0) {
        numStr = nil;
        textStr = [NSString stringWithFormat:@"%@", entryModel.activeCountInfo.text];
        combineStr = textStr;
    }
    NSMutableAttributedString *aStr = [[NSMutableAttributedString alloc] initWithString:combineStr];
    UIColor *numColor = isEmptyString(entryModel.activeCountInfo.numColor) ? [UIColor themeRed1] : [UIColor colorWithHexStr:entryModel.activeCountInfo.numColor];
    UIColor *textColor = isEmptyString(entryModel.activeCountInfo.textColor) ? [UIColor themeGray1] : [UIColor colorWithHexStr:entryModel.activeCountInfo.textColor];
    [aStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"DINAlternate-Bold" size: 14.0f] range:NSMakeRange(0, numStr.length)];
    [aStr addAttribute:NSForegroundColorAttributeName value:numColor range:NSMakeRange(0, numStr.length)];
    [aStr addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(numStr.length, textStr.length)];
    
    self.activeCountInfoLabel.attributedText = aStr;
    [self updateBubble];
}

- (void)updateBubble {
    FHDetailCommunityEntryModel *entryModel = self.currentData;
    if (!entryModel.activeInfo || entryModel.activeInfo.count <= 0) {
        return;
    }
    FHDetailCommunityEntryActiveInfoModel *model = entryModel.activeInfo[self.curWheelIndex];
    FHDetailCommunityEntryActiveInfoModel *nextModel = entryModel.activeInfo[(self.curWheelIndex + 1) % entryModel.activeInfo.count];
    UIColor *suggestColor = isEmptyString(model.suggestInfoColor) ? [UIColor colorWithHexStr:@"#9c6d43"] : [UIColor colorWithHexStr:model.suggestInfoColor];
    UIColor *nextSuggestColor = isEmptyString(nextModel.suggestInfoColor) ? [UIColor colorWithHexStr:@"#9c6d43"] : [UIColor colorWithHexStr:nextModel.suggestInfoColor];
    
    CGFloat labelWidth = [self.curBubble refreshWithAvatar:model.activeUserAvatar title:model.suggestInfo color:suggestColor];
    self.curBubble.frame = CGRectMake(SCREEN_WIDTH - 40 - (6 + 12 + 4 + 4 + labelWidth + 20), 14, labelWidth + 4 + 20, 26);
    self.curBubble.alpha = 1.0f;
    
    labelWidth = [self.flowBubble refreshWithAvatar:nextModel.activeUserAvatar title:nextModel.suggestInfo color:nextSuggestColor];
    self.flowBubble.frame = CGRectMake(SCREEN_WIDTH - 40 - (6 + 12 + 4 + 4 + labelWidth + 20), 50, labelWidth + 4 + 20, 26);
    self.flowBubble.alpha = 0.0f;
}

- (void)wheelSuggestionInfo {
    if (![self.currentData isKindOfClass:[FHDetailCommunityEntryModel class]]) {
        return;
    }
    FHDetailCommunityEntryModel *entryModel = self.currentData;
    if (entryModel.activeInfo.count == 0) {
        return;
    }
    [UIView animateWithDuration:0.4 animations:^{
        self.curBubble.frame = CGRectOffset(self.curBubble.frame, 0, -36.0f);
        self.curBubble.alpha = 0.0f;
        self.flowBubble.frame = CGRectOffset(self.flowBubble.frame, 0, -36.0f);
        self.flowBubble.alpha = 1.0f;
    }completion:^(BOOL finished) {
        FHCommunityUCGBubble *tempBubble = self.curBubble;
        self.curBubble = self.flowBubble;
        self.flowBubble = tempBubble;
        self.curWheelIndex = (self.curWheelIndex + 1) % entryModel.activeInfo.count;
        [self updateBubble];
    }];
}

- (BOOL)canWheel {
    if (![self.currentData isKindOfClass:[FHDetailCommunityEntryModel class]]) {
        return NO;
    }
    FHDetailCommunityEntryModel *entryModel = self.currentData;
    return entryModel.activeInfo.count >= 2;
}

- (void)fh_willDisplayCell {
    [super fh_willDisplayCell];
    [self startWheel];
}

- (void)fh_didEndDisplayingCell {
    [super fh_didEndDisplayingCell];
    [self stopWheel];
}

- (void)vc_viewDidAppear:(BOOL)animated {
    [self startWheel];
}

- (void)vc_viewDidDisappear:(BOOL)animated {
    [self stopWheel];
}

- (void)dealloc
{
    [self stopWheel];
}

- (void)startWheel {
    if (self.wheelTimer) {
        [self.wheelTimer invalidate];
    }
    if (![self canWheel]) {
        return;
    }
    self.wheelTimer = [NSTimer scheduledNoRetainTimerWithTimeInterval:2.0f target:self selector:@selector(wheelSuggestionInfo) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.wheelTimer forMode:NSRunLoopCommonModes];
}

- (void)stopWheel {
    if (self.wheelTimer) {
        [self.wheelTimer invalidate];
        self.wheelTimer = nil;
    }
}

- (NSString *)elementTypeString:(FHHouseType)houseType
{
    return @"community_group";
}
@end
