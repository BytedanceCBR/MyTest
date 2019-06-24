//
// Created by zhulijun on 2019-06-24.
//

#import "FHDetailCommunityEntryCell.h"
#import "BDWebImage.h"
#import "NSTimer+NoRetain.h"
#import "TTBaseMacro.h"
#import "IMConsDefine.h"


@interface FHDetailCommunityEntryCell () <FHDetailVCViewLifeCycleProtocol>
@property(nonatomic, strong) UILabel *activeCountInfoLabel;
@property(nonatomic, strong) UIImageView *activeUserAvatarView;
@property(nonatomic, strong) UILabel *suggestInfoLabel;
@property(nonatomic, strong) UIView *suggestionBackView;
@property(nonatomic, strong) UIView *suggestionContainerView;
@property(nonatomic, strong) UIImageView *activeUserAvatarView1;
@property(nonatomic, strong) UILabel *suggestInfoLabel1;
@property(nonatomic, strong) UIView *suggestionBackView1;
@property(nonatomic, strong) UIView *suggestionContainerView1;
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
    _activeCountInfoLabel = [[UILabel alloc] init];
    _activeCountInfoLabel.font = [UIFont systemFontOfSize:14.0f];
    _activeCountInfoLabel.numberOfLines = 1;
    _activeCountInfoLabel.textAlignment = NSTextAlignmentLeft;

    _activeUserAvatarView = [[UIImageView alloc] init];
    _activeUserAvatarView.layer.cornerRadius = 7.0f;
    _activeUserAvatarView.layer.borderWidth = 0.5f;
    _activeUserAvatarView.layer.borderColor = [UIColor themeRed3].CGColor;
    _activeUserAvatarView.clipsToBounds = YES;

    _suggestInfoLabel = [[UILabel alloc] init];
    _suggestInfoLabel.textColor = [UIColor themeRed1];
    _suggestInfoLabel.backgroundColor = [UIColor clearColor];
    _suggestInfoLabel.font = [UIFont systemFontOfSize:10.0f];
    _suggestInfoLabel.numberOfLines = 1;

    _suggestionBackView = [[UIView alloc] init];
    _suggestionBackView.layer.cornerRadius = 10.0f;
    _suggestionBackView.backgroundColor = [[UIColor themeRed3] colorWithAlphaComponent:0.1];

    _suggestionContainerView = [[UIView alloc] init];
    _suggestionContainerView.frame = CGRectMake(SCREEN_WIDTH - 20 - 6 - 12- 160, 0, 160, 40);

    _activeUserAvatarView1 = [[UIImageView alloc] init];
    _activeUserAvatarView1.layer.cornerRadius = 7.0f;
    _activeUserAvatarView1.layer.borderWidth = 0.5f;
    _activeUserAvatarView1.layer.borderColor = [UIColor themeRed3].CGColor;
    _activeUserAvatarView1.clipsToBounds = YES;

    _suggestInfoLabel1 = [[UILabel alloc] init];
    _suggestInfoLabel1.textColor = [UIColor themeRed1];
    _suggestInfoLabel1.backgroundColor = [UIColor clearColor];
    _suggestInfoLabel1.font = [UIFont systemFontOfSize:10.0f
    _suggestInfoLabel1.numberOfLines = 1;

    _suggestionBackView1 = [[UIView alloc] init];
    _suggestionBackView1.layer.cornerRadius = 10.0f;
    _suggestionBackView1.backgroundColor = [[UIColor themeRed3] colorWithAlphaComponent:0.1];

    _suggestionContainerView1 = [[UIView alloc] init];
    _suggestionContainerView1.frame = CGRectMake(SCREEN_WIDTH - 20 - 6 - 12 - 160, 40, 160, 40);

    _arrowView.frame = CGRectMake(SCREEN_WIDTH - 20 - 6 - 12, 14, 12, 12);

    _backView = [[UIView alloc] init];
    _backView.layer.cornerRadius = 4.0f;
    _backView.backgroundColor = [[UIColor themeRed3] colorWithAlphaComponent:0.1];
    _backView.frame = CGRectMake(20, 10, SCREEN_WIDTH - 40, 40);

    _arrowView = [[UIImageView alloc] init];
    _arrowView.image = [UIImage imageNamed:@"detail_red_arrow_right"];

    [_suggestionBackView addSubview:_activeUserAvatarView];
    [_suggestionBackView addSubview:_suggestInfoLabel];

    [_suggestionBackView1 addSubview:_activeUserAvatarView1];
    [_suggestionBackView1 addSubview:_suggestInfoLabel1];

    [_suggestionContainerView addSubview:_suggestionBackView];
    [_suggestionContainerView1 addSubview:_suggestionBackView1];

    [_backView addSubview:_activeCountInfoLabel];
    [_backView addSubview:_suggestionContainerView];
    [_backView addSubview:_suggestionContainerView1];
    [_backView addSubview:_arrowView];
    _backView.clipsToBounds = YES;

    [self.contentView addSubview:_backView];

}

- (void)initConstraints {

    [_activeCountInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.backView).offset(10);
        make.right.mas_equalTo(self.suggestionContainerView.mas_left).offset(-10);
        make.centerY.mas_equalTo(self.backView);
        make.height.mas_equalTo(20);
    }];

    [_suggestionBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.arrowView.mas_left).offset(-4);
        make.left.mas_equalTo(self.activeUserAvatarView).offset(-4);
        make.centerY.mas_equalTo(self.backView);
        make.height.mas_equalTo(20);
    }];

    [_activeUserAvatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.suggestionBackView).offset(4);
        make.centerY.mas_equalTo(self.suggestionBackView);
        make.width.height.mas_equalTo(14);
    }];

    [_suggestInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.activeUserAvatarView.mas_right).offset(2.0f);
        make.centerY.mas_equalTo(self.suggestionBackView);
        make.height.mas_equalTo(14);
        make.right.mas_equalTo(self.suggestionBackView);
    }];

    [_suggestionBackView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.suggestionContainerView1).offset(-4);
        make.left.mas_equalTo(self.activeUserAvatarView1).offset(-4);
        make.centerY.mas_equalTo(self.backView);
        make.height.mas_equalTo(20);
    }];

    [_activeUserAvatarView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.suggestionBackView1).offset(4);
        make.centerY.mas_equalTo(self.suggestionBackView1);
        make.width.height.mas_equalTo(14);
    }];

    [_suggestInfoLabel1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.activeUserAvatarView.mas_right).offset(2.0f);
        make.centerY.mas_equalTo(self.suggestionBackView1);
        make.height.mas_equalTo(14);
        make.right.mas_equalTo(self.suggestionBackView1);
    }];
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailCommunityEntryModel class]]) {
        return;
    }
    self.currentData = data;
    self.curWheelIndex = 0;

    FHDetailCommunityEntryModel *entryModel = data;
    self.activeCountInfoLabel.text = [NSString stringWithFormat:@"%@%@", entryModel.activeCountInfo.count, entryModel.activeCountInfo.text];
    [self refreshSuggestionInfoWithIndex:self.curWheelIndex];
}

- (void)refreshSuggestionInfoWithIndex:(NSUInteger)index {
    if (![self.currentData isKindOfClass:[FHDetailCommunityEntryModel class]]) {
        return;
    }

    FHDetailCommunityEntryModel *entryModel = self.currentData;
    if (entryModel.activeInfo.count == 0 || index >= entryModel.activeInfo.count) {
        return;
    }
    NSUInteger index1 = self.curWheelIndex + 1;
    index1 = index1 % entryModel.activeInfo.count;
    FHDetailCommunityEntryActiveInfoModel *model;
    FHDetailCommunityEntryActiveInfoModel *model1;
//    if (index % 2 == 0) {
    model = entryModel.activeInfo[index];
    model1 = entryModel.activeInfo[index1];
//    } else {
//        model1 = entryModel.activeInfo[index];
//        model = entryModel.activeInfo[index1];
//    }

    [self.activeUserAvatarView bd_setImageWithURL:[NSURL URLWithString:model.activeUserAvatar]];
    self.suggestInfoLabel.text = model.suggestInfo;
    CGSize preferSize = [self.suggestInfoLabel sizeThatFits:CGSizeMake(140, 14)];
    [_suggestInfoLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(preferSize.width);
    }];

    [self.activeUserAvatarView1 bd_setImageWithURL:[NSURL URLWithString:model1.activeUserAvatar]];
    self.suggestInfoLabel1.text = model1.suggestInfo;
    CGSize preferSize1 = [self.suggestInfoLabel1 sizeThatFits:CGSizeMake(140, 14)];
    [_suggestInfoLabel1 mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(preferSize1.width);
    }];
}

- (void)wheelSuggestionInfo {
    if (![self.currentData isKindOfClass:[FHDetailCommunityEntryModel class]]) {
        return;
    }
    FHDetailCommunityEntryModel *entryModel = self.currentData;
    if (entryModel.activeInfo.count == 0) {
        return;
    }
    CGFloat distance = 40.0f;
    WeakSelf;
    [UIView animateWithDuration:0.5 animations:^{
        StrongSelf;
        wself.suggestionContainerView.frame = CGRectOffset(wself.suggestionBackView.frame, 0, distance);
        wself.suggestionContainerView1.frame = CGRectOffset(wself.suggestionBackView1.frame, 0, distance);
    }                completion:^(BOOL finished) {
        StrongSelf;
        wself.suggestionContainerView.frame = CGRectOffset(wself.suggestionBackView.frame, 0, -distance);
        wself.suggestionContainerView1.frame = CGRectOffset(wself.suggestionBackView1.frame, 0, -distance);
        NSInteger index = wself.curWheelIndex + 1;
        wself.curWheelIndex = index % entryModel.activeInfo.count;
        [wself refreshSuggestionInfoWithIndex:wself.curWheelIndex];
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
    self.wheelTimer = [NSTimer scheduledNoRetainTimerWithTimeInterval:2.0f target:self selector:@selector(wheelSuggestionInfo) userInfo:nil repeats:YES];
    self.curWheelIndex = self.curWheelIndex + 1;
    [self.wheelTimer fire];
}

- (void)stopWheel {
    if (self.wheelTimer) {
        [self.wheelTimer invalidate];
        self.wheelTimer = nil;
    }
}

@end
