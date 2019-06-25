//
// Created by zhulijun on 2019-06-24.
//

#import "FHDetailCommunityEntryCell.h"
#import "BDWebImage.h"
#import "NSTimer+NoRetain.h"
#import "TTBaseMacro.h"
#import "IMConsDefine.h"
#import "FHCommunitySuggestionBubble.h"


@interface FHDetailCommunityEntryCell () <FHDetailVCViewLifeCycleProtocol>
@property(nonatomic, strong) UILabel *activeCountInfoLabel;
@property(nonatomic, strong) FHCommunitySuggestionBubble *bubble0;
@property(nonatomic, strong) FHCommunitySuggestionBubble *bubble1;
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
    [self initConstraints];
}

- (void)initViews {
    _backView = [[UIView alloc] init];
    _backView.layer.cornerRadius = 4.0f;
    _backView.backgroundColor = [[UIColor themeRed3] colorWithAlphaComponent:0.1];
    _backView.frame = CGRectMake(20, 10, SCREEN_WIDTH - 40, 40);

    _activeCountInfoLabel = [[UILabel alloc] init];
    _activeCountInfoLabel.font = [UIFont systemFontOfSize:14.0f];
    _activeCountInfoLabel.numberOfLines = 1;
    _activeCountInfoLabel.textAlignment = NSTextAlignmentLeft;

    _bubble0 = [[FHCommunitySuggestionBubble alloc] initWithFrame: CGRectMake(_backView.frame.size.width - 22 - 160, 10, 160, 20)];
    _bubble1 = [[FHCommunitySuggestionBubble alloc] initWithFrame: CGRectMake(_backView.frame.size.width - 22 - 160, 40, 160, 20)];

    _arrowView = [[UIImageView alloc] init];
    _arrowView.image = [UIImage imageNamed:@"detail_red_arrow_right"];

    [_backView addSubview:_activeCountInfoLabel];
    [_backView addSubview:_bubble0];
    [_backView addSubview:_bubble1];
    [_backView addSubview:_arrowView];
    _backView.clipsToBounds = YES;
    [self.contentView addSubview:_backView];
}

- (void)initConstraints {
//    [_activeCountInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(self.backView).offset(10);
//        make.right.mas_equalTo(self.bubble0.mas_left).offset(-10).priorityLow();
//        make.centerY.mas_equalTo(self.backView);
//        make.height.mas_equalTo(20);
//    }];

    [_arrowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bubble0.mas_right);
        make.left.mas_equalTo(self.bubble1.mas_right);
        make.centerY.mas_equalTo(self.backView);
        make.width.height.mas_equalTo(12);
        make.right.mas_equalTo(self.backView).offset(-6).priorityHigh();
    }];
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
    FHDetailCommunityEntryActiveInfoModel *model = entryModel.activeInfo[self.curWheelIndex];
    [self.bubble0 refreshWithAvatar:model.activeUserAvatar title:model.suggestInfo];
    NSUInteger nextIndex = (self.curWheelIndex + 1) % entryModel.activeInfo.count;
    [self prepareNext:self.bubble1 model:entryModel.activeInfo[nextIndex]];
}

- (void)prepareNext:(FHCommunitySuggestionBubble *)bubble model:(FHDetailCommunityEntryActiveInfoModel *)model {
    if (!model) {
        return;
    }
    NSLog(@"zlj prepareNext:%@",bubble);
    [bubble refreshWithAvatar:model.activeUserAvatar title:model.suggestInfo];
}

- (void)wheelSuggestionInfo {
    if (![self.currentData isKindOfClass:[FHDetailCommunityEntryModel class]]) {
        return;
    }
    FHDetailCommunityEntryModel *entryModel = self.currentData;
    if (entryModel.activeInfo.count == 0) {
        return;
    }
    FHCommunitySuggestionBubble *curBubble = self.curWheelIndex % 2 == 0 ? self.bubble0 : self.bubble1;
    FHCommunitySuggestionBubble *popBuuble = self.curWheelIndex % 2 == 0 ? self.bubble1 : self.bubble0;
    NSLog(@"zlj cur:%@ pop:%@",curBubble,popBuuble);
    NSLog(@"zlj curFrame:%@ popFrame:%@",NSStringFromCGRect(curBubble.frame),NSStringFromCGRect(popBuuble.frame));
    WeakSelf;
    [UIView animateWithDuration:0.5 animations:^{
        StrongSelf;
//        curBubble.alpha = 0;
//        popBuuble.alpha = 1;
        curBubble.frame = CGRectOffset(curBubble.frame, 0, -30.0f);
        popBuuble.frame = CGRectOffset(popBuuble.frame, 0, -30.0f);
    }completion:^(BOOL finished) {
        StrongSelf;
        NSLog(@"zlj animatefinish: %@,curFrame:%@ popFrame:%@",finished ? @"YES" : @"NO",NSStringFromCGRect(curBubble.frame),NSStringFromCGRect(popBuuble.frame));
        curBubble.frame = CGRectOffset(curBubble.frame, 0, 60.0f);
        NSLog(@"zlj curIndex:%d",wself.curWheelIndex);
        wself.curWheelIndex = (wself.curWheelIndex + 1) % entryModel.activeInfo.count;
        NSUInteger nextIndex = (wself.curWheelIndex + 1) % entryModel.activeInfo.count;
        [wself prepareNext:curBubble model:entryModel.activeInfo[nextIndex]];
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
}

- (void)vc_viewDidDisappear:(BOOL)animated {
    [self stopWheel];
}

- (void)startWheel {
    if (self.wheelTimer) {
        [self.wheelTimer invalidate];
    }
    if (![self canWheel]) {
        return;
    }
    self.wheelTimer = [NSTimer scheduledNoRetainTimerWithTimeInterval:4.0f target:self selector:@selector(wheelSuggestionInfo) userInfo:nil repeats:YES];
    [self.wheelTimer fire];
}

- (void)stopWheel {
    if (self.wheelTimer) {
        [self.wheelTimer invalidate];
        self.wheelTimer = nil;
    }
}

@end
