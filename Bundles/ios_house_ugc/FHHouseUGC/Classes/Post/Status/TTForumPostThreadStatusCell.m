 //
//  TTForumPostThreadStatusCell.m
//  Article
//
//  Created by 徐霜晴 on 16/10/8.
//
//

#import "TTForumPostThreadStatusCell.h"
#import "TTThemedUploadingStatusCellProgressBar.h"
#import "SSThemed.h"
#import "TTAlphaThemedButton.h"
#import "TTPostThreadCenter.h"
#import "TTTrackerWrapper.h"
#import "TTUGCAttributedLabel.h"
#import "TTAccountBusiness.h"
#import "TTRichSpanText.h"
#import "TTRichSpanText+Link.h"
#import "TTRichSpanText+Emoji.h"
#import "TTRichSpanText+Image.h"
#import "TTUGCEmojiParser.h"
#import "TTVideoPublishMonitor.h"
#import "TTReachability.h"
#import <ReactiveObjC/ReactiveObjC.h>

static inline CGFloat postThreadStatusCellCoverImageViewLeftMargin() {
    return 15.0f;
}

static inline CGFloat postThreadStatusCellCoverImageViewTopMargin() {
    return 10.0f;
}

static inline CGFloat postThreadStatusCellCoverPlayingIconSize() {
    CGFloat size = 0;
    switch ([TTDeviceHelper deviceWidthType]) {
        case TTDeviceWidthModePad:
        case TTDeviceWidthMode414:
        case TTDeviceWidthMode375:
        size = 30.0f;
        break;
        
        case TTDeviceWidthMode320:
        size = 27.0f;
        break;
    }
    
    return size;
}

static inline CGFloat postThreadStatusCellCoverImageViewSize() {
    CGFloat size = 0;
    switch ([TTDeviceHelper deviceWidthType]) {
        case TTDeviceWidthModePad:
        case TTDeviceWidthMode414:
        case TTDeviceWidthMode375:
        size = 50.0f;
        break;
        
        case TTDeviceWidthMode320:
        size = 45.0f;
        break;
    }
    
    return size;
}

static inline CGFloat postThreadStatusCellCoverImageViewBottomMargin() {
    return 10.0f;
}

static inline CGFloat postThreadStatusCellTitleLabelTopMargin() {
    return 10.0f;
}

static inline CGFloat postThreadStatusCellTitleLabelLeftMarginWithoutImage() {
    return 15.0f;
}

static inline CGFloat postThreadStatusCellTitleLabelLeftMarginToImage() {
    return 10.0f;
}

static inline CGFloat postThreadStatusCellTitleLabelRightMarginWithImage() {
    return 10.5f;
}

static inline CGFloat postThreadStatusCellTitleLabelRightMarginWithoutImage() {
    return 10.5f;
}

static inline CGFloat postThreadStatusCellUploadingViewLeftMarginWithoutImage() {
    return 15.0f;
}

static inline CGFloat postThreadStatusCellUploadingViewRightMargin() {
    return 15.0f;
}

static inline CGFloat postThreadStatusCellUploadingLabelBottomMargin() {
    return 10.0f;
}

static inline CGFloat postThreadStatusCellProgressBarHeight() {
    return 2.0f;
}

static inline CGFloat postThreadStatusCellTitleLabelFontSize() {
    CGFloat size = 0;
    switch ([TTDeviceHelper deviceWidthType]) {
        case TTDeviceWidthModePad:
        case TTDeviceWidthMode414:
        case TTDeviceWidthMode375:
        size = 17.0f;
        break;
        
        case TTDeviceWidthMode320:
        size = 15.5f;
        break;
    }
    
    return size;
}

static inline CGFloat postThreadStatusCellUploadingLabelFontSize() {
    CGFloat size = 0;
    switch ([TTDeviceHelper deviceWidthType]) {
        case TTDeviceWidthModePad:
        case TTDeviceWidthMode414:
        case TTDeviceWidthMode375:
        size = 12.0f;
        break;
        
        case TTDeviceWidthMode320:
        size = 10.0f;
        break;
    }
    
    return size;
}

static inline CGFloat postThreadStatusCellFailureLabelFontSize() {
    CGFloat size = 0;
    switch ([TTDeviceHelper deviceWidthType]) {
        case TTDeviceWidthModePad:
        case TTDeviceWidthMode414:
        case TTDeviceWidthMode375:
        size = 12.0f;
        break;
        
        case TTDeviceWidthMode320:
        size = 10.0f;
        break;
    }
    
    return size;
}

static inline CGFloat postThreadStatusCellButtonFontSize() {
    CGFloat size = 0;
    switch ([TTDeviceHelper deviceWidthType]) {
        case TTDeviceWidthModePad:
        case TTDeviceWidthMode414:
        case TTDeviceWidthMode375:
        size = 12.0f;
        break;
        
        case TTDeviceWidthMode320:
        size = 10.0f;
        break;
    }
    
    return size;
}

static inline CGFloat postThreadStatusCellFailureLabelLeftMarginToFailureIcon() {
    return 5.0f;
}

static inline CGFloat postThreadStatusCellMarginBetweenButtons() {
    return 30.0f;
}

static inline CGFloat postThreadStatusCellHeightWithoutProgressBar() {
    return postThreadStatusCellCoverImageViewTopMargin() + postThreadStatusCellCoverImageViewSize() + postThreadStatusCellCoverImageViewBottomMargin() + [TTDeviceHelper ssOnePixel];
}

static const CGFloat kFailureIconSize = 14.0f;

static const CGFloat kCellButtonWidth = 44.0;
static const CGFloat kCellButtonHeight = 30.0;

@interface TTForumPostThreadStatusCell ()

@property (nonatomic, strong) SSThemedImageView *coverImageView;
@property (nonatomic, strong) UIImageView *playingIcon;

@property (nonatomic, strong) TTUGCAttributedLabel *titleLabel;

@property (nonatomic, strong) SSThemedLabel *uploadingLabel;

@property (nonatomic, strong) SSThemedImageView *failureIcon;
@property (nonatomic, strong) SSThemedLabel *failureLabel;

@property (nonatomic, strong) TTAlphaThemedButton *retryButton;
@property (nonatomic, strong) TTAlphaThemedButton *deleteButton;

@property (nonatomic, strong) TTThemedUploadingStatusCellProgressBar *progressBar;

@property (nonatomic, strong) SSThemedView *separatorLine;

@property (nonatomic, copy) TTPostThreadTaskProgressBlock progressBlock;

@end

@implementation TTForumPostThreadStatusCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColorThemeKey = kColorBackground2;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setupSubviews];
        
        WeakSelf;
        [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:TTReachabilityChangedNotification object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable x) {
            StrongSelf;
            [self retryIfWifiAvailabe:x];
        }];
    }
    return self;
}

- (void)setupSubviews {
    [self.contentView addSubview:self.coverImageView];
    [self.contentView addSubview:self.titleLabel];
    
    [self.contentView addSubview:self.failureIcon];
    [self.contentView addSubview:self.failureLabel];
    
    [self.contentView addSubview:self.uploadingLabel];
    
    [self.contentView addSubview:self.retryButton];
    [self.contentView addSubview:self.deleteButton];
    
    [self.contentView addSubview:self.progressBar];
    [self.contentView addSubview:self.separatorLine];
}

- (NSDictionary *)titleLabelAttributedDictionary
{
    NSMutableDictionary * attributeDictionary = @{}.mutableCopy;
    UIFont *fontSize = [UIFont systemFontOfSize:postThreadStatusCellTitleLabelFontSize()];;
    [attributeDictionary setValue:fontSize forKey:NSFontAttributeName];
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 0;
    
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    [attributeDictionary setValue:paragraphStyle forKey:NSParagraphStyleAttributeName];
    [attributeDictionary setValue:[UIColor tt_themedColorForKey:kColorText1] forKey:NSForegroundColorAttributeName];
    return attributeDictionary.copy;
}

- (void)setStatusModel:(TTPostThreadTaskStatusModel *)statusModel {
    
    if (self.progressBlock) {
        [_statusModel removeProgressBlock:self.progressBlock];
    }
    if(!_statusModel && (statusModel.status == TTPostTaskStatusFailed)){ //第一次显示，这个时候需要判断WIFI，然后重新上传上次失败的视频
        dispatch_async(dispatch_get_main_queue(), ^{
            [self retryIfWifiAvailabe:nil];
        });
    }
    _statusModel = statusModel;
    
    WeakSelf;
    self.progressBlock = ^(CGFloat progress){
        StrongSelf;
        [self.progressBar setProgress:progress animated:YES];
    };
    [statusModel addProgressBlock:self.progressBlock];
    
    [self.progressBar setProgress:statusModel.uploadingProgress animated:NO];
    
    NSString *titleStr = statusModel.title;
    if (isEmptyString(titleStr)) {
        self.titleLabel.attributedText = nil;
        return;
    }
    TTRichSpans *richSpans = [TTRichSpans richSpansForJSONString:statusModel.titleRichSpan];
    TTRichSpanText *richTitle = [[TTRichSpanText alloc] initWithText:titleStr richSpans:richSpans];
    
    TTRichSpanText *titleRichSpanText = [[richTitle replaceWhitelistLinks] replaceImageLinksWithIgnoreFlag:NO];
    NSAttributedString *attrStr = [TTUGCEmojiParser parseInCoreTextContext:titleRichSpanText.text fontSize:postThreadStatusCellTitleLabelFontSize()];
    
    NSDictionary *attrDic = [self titleLabelAttributedDictionary];
    NSMutableAttributedString *mutableAttributedString = [attrStr mutableCopy];
    [mutableAttributedString addAttributes:attrDic range:NSMakeRange(0, attrStr.length)];
    self.titleLabel.text = [mutableAttributedString copy];
    
    switch (statusModel.status) {
        case TTPostTaskStatusFailed:
            self.failureIcon.hidden = NO;
            self.failureLabel.hidden = NO;
            self.uploadingLabel.hidden = YES;
            self.retryButton.hidden = (self.statusModel.failureWordingType == TTForumPostThreadFailureWordingVideoNotFound);
            self.deleteButton.hidden = NO;
            self.progressBar.hidden = YES;
            break;
        case TTPostTaskStatusPosting:
            self.failureIcon.hidden = YES;
            self.failureLabel.hidden = YES;
            self.uploadingLabel.hidden = NO;
            self.retryButton.hidden = YES;
            self.deleteButton.hidden = (statusModel.taskType != TTPostTaskTypeVideo);
            self.progressBar.hidden = NO;
            break;
        default:
            self.failureIcon.hidden = YES;
            self.failureLabel.hidden = YES;
            self.uploadingLabel.hidden = YES;
            self.retryButton.hidden = YES;
            self.deleteButton.hidden = YES;
            self.progressBar.hidden = YES;
            break;
    }
    
    self.coverImageView.hidden = !statusModel.coverImage;
    [self.coverImageView setImage:nil];
    [self.coverImageView setImage:statusModel.coverImage];
    
    // 只有视频在上传过程中有删除键
    self.playingIcon.hidden = (self.statusModel.taskType != TTPostTaskTypeVideo);
    
    // 文件不存在时特殊样式
    switch (self.statusModel.failureWordingType) {
        case TTForumPostThreadFailureWordingNetworkError:
            self.failureLabel.text = @"网络异常，发布失败";
            break;
        case TTForumPostThreadFailureWordingServiceError:
            self.failureLabel.text = @"服务异常，发布失败";
            break;
        case TTForumPostThreadFailureWordingVideoNotFound:
            self.failureLabel.text = @"文件不存在";
            break;
        default:
            break;
    }
}

- (void)updateUploadingProgress:(CGFloat)progress {
    [self.progressBar setProgress:progress animated:YES];
}

+ (CGFloat)heightForStatusModel:(TTPostThreadTaskStatusModel *)statusModel {
    return [self heightForStatus:statusModel.status];
}

+ (CGFloat)heightForStatus:(TTPostTaskStatus)status {
    switch (status) {
        case TTPostTaskStatusPosting:
            return postThreadStatusCellHeightWithoutProgressBar() + postThreadStatusCellProgressBarHeight();
        case TTPostTaskStatusFailed:
            return postThreadStatusCellHeightWithoutProgressBar();
        default:
            return 0;
    }
    return 0;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self layoutTitleLabel];
    [self layoutUploadingView];
    [self layoutFailureView];
    [self layoutButtons];
    [self layoutSeparatorLine];
}

- (void)layoutTitleLabel {
    [self.titleLabel sizeToFit];
    if (self.statusModel.coverImage) {
        CGFloat titleLabelLeftMargin = postThreadStatusCellCoverImageViewLeftMargin() + postThreadStatusCellCoverImageViewSize() + postThreadStatusCellTitleLabelLeftMarginToImage();
        self.titleLabel.frame = CGRectMake(titleLabelLeftMargin,
                                           postThreadStatusCellTitleLabelTopMargin(),
                                           CGRectGetWidth(self.contentView.bounds) - titleLabelLeftMargin - postThreadStatusCellTitleLabelRightMarginWithImage(),
                                           CGRectGetHeight(self.titleLabel.frame));
    }
    else {
        self.titleLabel.frame = CGRectMake(postThreadStatusCellTitleLabelLeftMarginWithoutImage(),
                                           postThreadStatusCellTitleLabelTopMargin(),
                                           CGRectGetWidth(self.contentView.bounds) - postThreadStatusCellTitleLabelLeftMarginWithoutImage() - postThreadStatusCellTitleLabelRightMarginWithoutImage(),
                                           CGRectGetHeight(self.titleLabel.frame));
    }
}

- (void)layoutUploadingView {
    
    [self.uploadingLabel sizeToFit];
    self.uploadingLabel.bottom = postThreadStatusCellHeightWithoutProgressBar() - postThreadStatusCellUploadingLabelBottomMargin();
    if (self.statusModel.coverImage) {
        self.uploadingLabel.left = postThreadStatusCellCoverImageViewLeftMargin() + postThreadStatusCellCoverImageViewSize() + postThreadStatusCellTitleLabelLeftMarginToImage();
    }
    else {
        self.uploadingLabel.left = postThreadStatusCellUploadingViewLeftMarginWithoutImage();
    }
}

- (void)layoutFailureView {
    
    [self.failureLabel sizeToFit];
    
    self.failureLabel.bottom = postThreadStatusCellHeightWithoutProgressBar() - postThreadStatusCellUploadingLabelBottomMargin();
    if (self.statusModel.coverImage) {
        self.failureLabel.left = postThreadStatusCellCoverImageViewLeftMargin() + postThreadStatusCellCoverImageViewSize() + postThreadStatusCellTitleLabelLeftMarginToImage() + kFailureIconSize + postThreadStatusCellFailureLabelLeftMarginToFailureIcon();
    }
    else {
        self.failureLabel.left = postThreadStatusCellUploadingViewLeftMarginWithoutImage() + kFailureIconSize + postThreadStatusCellFailureLabelLeftMarginToFailureIcon();
    }
    
    self.failureIcon.center = CGPointMake(CGRectGetMinX(self.failureLabel.frame) - postThreadStatusCellFailureLabelLeftMarginToFailureIcon() - kFailureIconSize / 2.0, CGRectGetMidY(self.failureLabel.frame));
}

- (void)layoutButtons {
    [self.deleteButton.titleLabel sizeToFit];
    self.deleteButton.center = CGPointMake(CGRectGetWidth(self.bounds) - postThreadStatusCellUploadingViewRightMargin() - CGRectGetWidth(self.deleteButton.titleLabel.bounds) / 2.0, CGRectGetMidY(self.uploadingLabel.frame));
    
    [self.retryButton.titleLabel sizeToFit];
    self.retryButton.center = CGPointMake(CGRectGetWidth(self.bounds) - postThreadStatusCellUploadingViewRightMargin() - CGRectGetWidth(self.deleteButton.titleLabel.bounds) - postThreadStatusCellMarginBetweenButtons() - CGRectGetWidth(self.retryButton.titleLabel.bounds) / 2.0, CGRectGetMidY(self.uploadingLabel.frame));
}

- (void)layoutSeparatorLine {
    self.separatorLine.frame = CGRectMake(0, CGRectGetHeight(self.contentView.bounds) - [TTDeviceHelper ssOnePixel], CGRectGetWidth(self.contentView.bounds), [TTDeviceHelper ssOnePixel]);
}

#pragma mark - accessors

- (SSThemedImageView *)coverImageView {
    if (!_coverImageView) {
        _coverImageView = [[SSThemedImageView alloc] initWithFrame:CGRectMake(postThreadStatusCellCoverImageViewLeftMargin(), postThreadStatusCellCoverImageViewTopMargin(), postThreadStatusCellCoverImageViewSize(), postThreadStatusCellCoverImageViewSize())];
        _coverImageView.contentMode = UIViewContentModeScaleAspectFill;
        _coverImageView.clipsToBounds = YES;
        self.playingIcon.center = CGPointMake(CGRectGetMidX(_coverImageView.bounds), CGRectGetMidY(_coverImageView.bounds));
        [_coverImageView addSubview:self.playingIcon];
        _coverImageView.enableNightCover = YES;
    }
    return _coverImageView;
}

- (UIImageView *)playingIcon {
    if (!_playingIcon) {
        _playingIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, postThreadStatusCellCoverPlayingIconSize(), postThreadStatusCellCoverPlayingIconSize())];
        _playingIcon.image = [UIImage imageNamed:@"toutiaovideo"];
    }
    return _playingIcon;
}

- (TTUGCAttributedLabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[TTUGCAttributedLabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont systemFontOfSize:postThreadStatusCellTitleLabelFontSize()];
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    }
    return _titleLabel;
}

- (SSThemedLabel *)uploadingLabel {
    if (!_uploadingLabel) {
        _uploadingLabel = [[SSThemedLabel alloc] init];
        _uploadingLabel.textColorThemeKey = kColorText6;
        _uploadingLabel.font = [UIFont systemFontOfSize:postThreadStatusCellUploadingLabelFontSize()];
        _uploadingLabel.text = @"发送中...";
    }
    return _uploadingLabel;
}

- (SSThemedImageView *)failureIcon {
    if (!_failureIcon) {
        _failureIcon = [[SSThemedImageView alloc] initWithFrame:CGRectMake(0, 0, kFailureIconSize, kFailureIconSize)];
        [_failureIcon setImageName:@"error_message_icon"];
    }
    return _failureIcon;
}

- (SSThemedLabel *)failureLabel {
    if (!_failureLabel) {
        _failureLabel = [[SSThemedLabel alloc] init];
        _failureLabel.textColorThemeKey = kColorText4;
        _failureLabel.font = [UIFont systemFontOfSize:postThreadStatusCellFailureLabelFontSize()];
        _failureLabel.text = @"发送失败";
    }
    return _failureLabel;
}

- (TTAlphaThemedButton *)retryButton {
    if (!_retryButton) {
        _retryButton = [[TTAlphaThemedButton alloc] init];
        _retryButton.frame = CGRectMake(0, 0, kCellButtonWidth, kCellButtonHeight);
        [_retryButton setTitle:@"重试" forState:UIControlStateNormal];
        [_retryButton.titleLabel setFont:[UIFont systemFontOfSize:postThreadStatusCellButtonFontSize()]];
        [_retryButton addTarget:self action:@selector(retry:) forControlEvents:UIControlEventTouchUpInside];
        _retryButton.titleColorThemeKey = kColorText1;
    }
    return _retryButton;
}

- (TTAlphaThemedButton *)deleteButton {
    if (!_deleteButton) {
        _deleteButton = [[TTAlphaThemedButton alloc] init];
        _deleteButton.frame = CGRectMake(0, 0, kCellButtonWidth, kCellButtonHeight);
        [_deleteButton setTitle:@"删除" forState:UIControlStateNormal];
        [_deleteButton.titleLabel setFont:[UIFont systemFontOfSize:postThreadStatusCellButtonFontSize()]];
        [_deleteButton addTarget:self action:@selector(delete:) forControlEvents:UIControlEventTouchUpInside];
        _deleteButton.titleColorThemeKey = kColorText1;
    }
    return _deleteButton;
}

- (TTThemedUploadingStatusCellProgressBar *)progressBar {
    if (!_progressBar) {
        _progressBar = [[TTThemedUploadingStatusCellProgressBar alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.contentView.bounds) - postThreadStatusCellProgressBarHeight() - [TTDeviceHelper ssOnePixel], CGRectGetWidth(self.contentView.bounds), postThreadStatusCellProgressBarHeight())];
        [_progressBar setForegroundColorThemeKey:kColorBackground8];
        _progressBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    }
    return _progressBar;
}

- (SSThemedView *)separatorLine {
    if (!_separatorLine) {
        _separatorLine = [[SSThemedView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.contentView.bounds) - [TTDeviceHelper ssOnePixel], CGRectGetWidth(self.contentView.bounds), [TTDeviceHelper ssOnePixel])];
        _separatorLine.backgroundColorThemeKey = kColorLine7;
    }
    return _separatorLine;
}

- (void)setHighlighted:(BOOL)highlighted {
    //Do nothing;
}

#pragma mark - action

/**
 @discussion 当Wifi可用时候，自动重试发送
 *
 */
- (void)retryIfWifiAvailabe:(NSNotification *)notify{
    if((self.statusModel.status == TTPostTaskStatusFailed) && (self.statusModel.taskType == TTPostTaskTypeVideo) && TTNetworkWifiConnected()){ //暂时只针对小视频
//        id<TTPostVideoCenterProtocol> taskCenter = [BDContextGet() findServiceByName:TTPostVideoCenterServiceName];
//        [taskCenter resentVideoForFakeID:self.statusModel.fakeThreadId concernID:self.statusModel.concernID];
    }
}

- (void)retry:(id)sender {
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:2];
    [params setValue:@(self.statusModel.taskType) forKey:@"type"];
    [params setValue:@(self.statusModel.status) forKey:@"status"];
    if (self.statusModel.extraTrack.count > 0) {
        [params setValuesForKeysWithDictionary:self.statusModel.extraTrack];
    }
    [TTTrackerWrapper event:@"feed_publish_banner"
               label:@"republish"
               value:[TTAccountManager userID]
            extValue:[PGCAccountManager shareManager].currentLoginPGCAccount.mediaID
           extValue2:nil
                dict:params];
    if (self.statusModel.taskType == TTPostTaskTypeVideo) {
//        
//        id<TTPostVideoCenterProtocol> taskCenter = [BDContextGet() findServiceByName:TTPostVideoCenterServiceName];
//        [taskCenter resentVideoForFakeID:self.statusModel.fakeThreadId concernID:self.statusModel.concernID];
//        
////        [[TTPostThreadCenter sharedInstance_tt] resentVideoForFakeThreadID:self.statusModel.fakeThreadId concernID:self.statusModel.concernID];
    }
    else if (self.statusModel.taskType == TTPostTaskTypeThread) {
        [[TTPostThreadCenter sharedInstance_tt] resentThreadForFakeThreadID:self.statusModel.fakeThreadId concernID:self.statusModel.concernID];
    }
}

- (void)delete:(id)sender {
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:2];
    [params setValue:@(self.statusModel.taskType) forKey:@"type"];
    [params setValue:@(self.statusModel.status) forKey:@"status"];
    if (self.statusModel.extraTrack.count > 0) {
        [params setValuesForKeysWithDictionary:self.statusModel.extraTrack];
    }
    [TTTrackerWrapper event:@"feed_publish_banner"
               label:@"delete"
               value:[TTAccountManager userID]
            extValue:[PGCAccountManager shareManager].currentLoginPGCAccount.mediaID
           extValue2:nil
                dict:params];
    
    if (self.statusModel.taskType == TTPostTaskTypeVideo) {
//        id<TTPostVideoCenterProtocol> taskCenter = [BDContextGet() findServiceByName:TTPostVideoCenterServiceName];
//        [taskCenter removeVideoTaskForFakeID:self.statusModel.fakeThreadId concernID:self.statusModel.concernID];
    }
    else {
        [[TTPostThreadCenter sharedInstance_tt] removeTaskForFakeThreadID:self.statusModel.fakeThreadId concernID:self.statusModel.concernID];
    }
}

@end
