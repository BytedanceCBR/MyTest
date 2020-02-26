//
// Created by zhulijun on 2019-06-24.
//

#import "FHDetailCommunityEntryCell.h"
#import <BDWebImage/BDWebImage.h>
#import "NSTimer+NoRetain.h"
#import "TTBaseMacro.h"
#import "IMConsDefine.h"
#import "FHCommunitySuggestionBubble.h"
#import <FHHouseBase/UIImage+FIconFont.h>

@interface FHDetailCommunityEntryCell () <FHDetailVCViewLifeCycleProtocol>
@property(nonatomic, strong) UILabel *activeCountInfoLabel;
@property(nonatomic, strong) FHCommunitySuggestionBubble *curBubble;
@property(nonatomic, strong) FHCommunitySuggestionBubble *flowBubble;
@property(nonatomic, strong) UIImageView *arrowView;
@property(nonatomic, strong) UIView *backView;
@property(nonatomic, strong) NSTimer *wheelTimer;
@property(nonatomic) NSUInteger curWheelIndex;
@end

@implementation FHDetailCommunityEntryCell

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

- (void)initViews {
    _backView = [[UIView alloc] init];
    _backView.layer.cornerRadius = 4.0f;
    _backView.backgroundColor = [[UIColor themeRed3] colorWithAlphaComponent:0.1];

    _activeCountInfoLabel = [[UILabel alloc] init];
    [_activeCountInfoLabel setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    _activeCountInfoLabel.font = [UIFont systemFontOfSize:14.0f];
    _activeCountInfoLabel.numberOfLines = 1;
    _activeCountInfoLabel.textAlignment = NSTextAlignmentLeft;
    _activeCountInfoLabel.frame = CGRectMake(10, 10, SCREEN_WIDTH - 40 - 10 - 22 - 160, 20);

    _curBubble = [[FHCommunitySuggestionBubble alloc] initWithFrame:CGRectMake(_backView.frame.size.width - 22 - 160, 10, 160, 20)];
    _flowBubble = [[FHCommunitySuggestionBubble alloc] initWithFrame:CGRectMake(_backView.frame.size.width - 22 - 160, 40, 160, 20)];

    _arrowView = [[UIImageView alloc] init];
    _arrowView.image = ICON_FONT_IMG(12, @"\U0000e670", [UIColor themeRed1]);//@"detail_red_arrow_right"
    _arrowView.frame = CGRectMake(SCREEN_WIDTH - 40 - 6 - 12, 14, 12, 12);

    [_backView addSubview:_activeCountInfoLabel];
    [_backView addSubview:_curBubble];
    [_backView addSubview:_flowBubble];
    [_backView addSubview:_arrowView];
    _backView.clipsToBounds = YES;
    [self.contentView addSubview:_backView];

    [_backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView).insets(UIEdgeInsetsMake(10, 20, 10, 20));
        make.height.mas_equalTo(40);
    }];

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
    [aStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"DINAlternate-Bold" size:14.0f] range:NSMakeRange(0, numStr.length)];
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
    UIColor *suggestColor = isEmptyString(model.suggestInfoColor) ? [UIColor themeRed1] : [UIColor colorWithHexStr:model.suggestInfoColor];
    UIColor *nextSuggestColor = isEmptyString(nextModel.suggestInfoColor) ? [UIColor themeRed1] : [UIColor colorWithHexStr:nextModel.suggestInfoColor];

    CGFloat labelWidth = [self.curBubble refreshWithAvatar:model.activeUserAvatar title:model.suggestInfo color:suggestColor];
    self.curBubble.frame = CGRectMake(SCREEN_WIDTH - 40 - (6 + 12 + 4 + 4 + labelWidth + 20), 10, labelWidth + 4 + 20, 20);
    self.curBubble.alpha = 1.0f;
    
    labelWidth = [self.flowBubble refreshWithAvatar:nextModel.activeUserAvatar title:nextModel.suggestInfo color:nextSuggestColor];
    self.flowBubble.frame = CGRectMake(SCREEN_WIDTH - 40 - (6 + 12 + 4 + 4 + labelWidth + 20), 40, labelWidth + 4 + 20, 20);
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
    WeakSelf;
    [UIView animateWithDuration:0.4 animations:^{
        StrongSelf;
        wself.curBubble.frame = CGRectOffset(wself.curBubble.frame, 0, -30.0f);
        wself.curBubble.alpha = 0.0f;
        
        wself.flowBubble.frame = CGRectOffset(wself.flowBubble.frame, 0, -30.0f);
        wself.flowBubble.alpha = 1.0f;
    }completion:^(BOOL finished) {
        StrongSelf;
        FHCommunitySuggestionBubble *tempBubble = wself.curBubble;
        wself.curBubble = wself.flowBubble;
        wself.flowBubble = tempBubble;
        wself.curWheelIndex = (self.curWheelIndex + 1) % entryModel.activeInfo.count;
        [wself updateBubble];
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
