//
//  TTLiveCellBaseContentView.m
//  TTLive
//
//  Created by matrixzk on 3/30/16.
//
//

#import "TTLiveCellBaseContentView.h"
#import "TTLiveCellHelper.h"
#import "TTLiveMessage.h"
#import <TTAccountBusiness.h>

#import "TTDiggButton.h"
#import "TTNetworkManager.h"
#import "UIButton+TTAdditions.h"
#import "TTVerifyIconHelper.h"
#import "TTDeviceUIUtils.h"
#import "UIImage+Masking.h"

#pragma mark - TTLiveCellMetaInfoView
@interface TTLiveCellMetaInfoView ()

@property (nonatomic, strong) SSThemedImageView *vipView;

@end

@implementation TTLiveCellMetaInfoView
{
    TTLabel *_nickNameLabel;
    TTLabel *_timeLabel;
    TTLiveMessage *_message;
    BOOL _incomingMsg;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _nickNameLabel = [[TTLabel alloc] init];
        _nickNameLabel.textColorKey = kColorText3;
        _nickNameLabel.font = [UIFont systemFontOfSize:FontSizeOfNicknameLabel()];
        [self addSubview:_nickNameLabel];
        
        _timeLabel = [[TTLabel alloc] initWithFrame:CGRectZero];
        _timeLabel.textColorKey = kColorText9;
        _timeLabel.font = [UIFont systemFontOfSize:FontSizeOfSendTimeLabel()];
        [self addSubview:_timeLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    BOOL _isReplyedMsg = _message.isReplyedMsg;
    
    CGFloat widthOfNameLbl = _nickNameLabel.width;
    CGFloat widthOfTimeLbl = _timeLabel.width;
    
    CGFloat extraWidth = LeftPaddingOfMsgSendTimeLabel()
                        + widthOfTimeLbl
                        + ([_message.userVip boolValue] ? _vipView.width + LeftPaddingOfMsgSendTimeLabel() : 0);
    
    if (widthOfNameLbl + extraWidth > self.width - (_isReplyedMsg ? SidePaddingOfNicknameLabel() * 2 : 0)) {
        _nickNameLabel.width = self.width - (_isReplyedMsg ? SidePaddingOfNicknameLabel() * 2 : 0) - extraWidth;
    }
    
    if (_incomingMsg) {
        CGFloat offsetX = _isReplyedMsg ? SidePaddingOfNicknameLabel() : LeftPaddingOfNicknameLabel();
        
        _timeLabel.textColorKey = kColorText3;
        if (!(_message.cellLayout & TTLiveCellLayoutHiddenName)){
            _timeLabel.textColorKey = kColorText9;
            _nickNameLabel.origin = CGPointMake(offsetX, _isReplyedMsg ? TopPaddingOfReplyNicknameLabel() : 0);
            offsetX = _nickNameLabel.right + LeftPaddingOfMsgSendTimeLabel();
            if ([_message.userVip boolValue]) {
                _vipView.left = offsetX;
                _vipView.centerY = _nickNameLabel.centerY;
                offsetX = _vipView.right + LeftPaddingOfMsgSendTimeLabel();
            }
        }
        _timeLabel.origin = CGPointMake(offsetX, _isReplyedMsg ? TopPaddingOfReplyNicknameLabel() : 0);
    } else {
        CGFloat offsetX = CGRectGetWidth(self.frame) - LeftPaddingOfNicknameLabel() - extraWidth - _nickNameLabel.width - (_isReplyedMsg ? SidePaddingOfNicknameLabel() : 0);
        _timeLabel.origin = CGPointMake(offsetX, _nickNameLabel.bottom - _timeLabel.height);
        offsetX = _timeLabel.right + LeftPaddingOfMsgSendTimeLabel();
        _nickNameLabel.origin = CGPointMake(offsetX, _isReplyedMsg ? TopPaddingOfReplyNicknameLabel() : 0);
        offsetX = _nickNameLabel.right + LeftPaddingOfMsgSendTimeLabel();
        if ([_message.userVip boolValue]) {
            _vipView.left = offsetX;
            _vipView.centerY = _nickNameLabel.centerY;
        }
        _timeLabel.top = _isReplyedMsg ? TopPaddingOfReplyNicknameLabel() : 0;
    }
}

- (SSThemedImageView *)vipView {
    if (_vipView == nil) {
        _vipView = [[SSThemedImageView alloc] init];
        _vipView.size = CGSizeMake(14, 14);
        _vipView.image = [UIImage imageNamed:@"all_v_label"];
        _vipView.layer.cornerRadius = _vipView.width / 2;
        _vipView.layer.masksToBounds = YES;
        _vipView.enableNightCover = YES;
        [self addSubview:_vipView];
    }
    return _vipView;
}

- (void)setupInfoWithMessage:(TTLiveMessage *)message isIncomingMsg:(BOOL)isIncoming {
    _message = message;
    _incomingMsg = isIncoming;
    NSString *name = @"";
    if (!(_message.cellLayout & TTLiveCellLayoutHiddenName)){
        name = isEmptyString(_message.userDisplayName) ? @"爱看用户" : _message.userDisplayName;
        NSString *roleName = message.userRoleName;
        if (!(_message.cellLayout & TTLiveCellLayoutHiddenRoleName) && !isEmptyString(roleName)){
            name = [NSString stringWithFormat:@"%@ %@",roleName,name];
        }
    }
    _nickNameLabel.text = name;
    [_nickNameLabel sizeToFit:CGFLOAT_MAX];

    _timeLabel.text = _message.sendTime;
    [_timeLabel sizeToFit:CGFLOAT_MAX];
    
    if ([_message.userVip boolValue] && (!(_message.cellLayout & TTLiveCellLayoutHiddenName))) {
        self.vipView.hidden = NO;
    } else {
        _vipView.hidden = YES;
    }
    [self setNeedsLayout];
}

@end


#pragma mark - TTLiveCellMetaTextView

@interface TTLiveCellMetaTextView ()
@end

@implementation TTLiveCellMetaTextView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.textColor = [UIColor lightGrayColor];
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

@end


#pragma mark - TTLiveCellContentBaseView

@interface TTLiveCellBaseContentView ()
@property (nonatomic, strong) TTLiveCellMetaInfoView *topInfoView;
@property (nonatomic, strong) TTLiveMessage *message;
@property (nonatomic, assign) BOOL isIncomingMsg;
@property (nonatomic, assign) BOOL isReplyedMsg;
@end

@implementation TTLiveCellBaseContentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _topInfoView = [[TTLiveCellMetaInfoView alloc] initWithFrame:CGRectZero];
        [self addSubview:_topInfoView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _topInfoView.frame = CGRectMake((_message.cellLayout & TTLiveCellLayoutBubbleCoverTop) ? _isReplyedMsg ? 0 : OriginXOfCellContent() : 0,
                                    (_message.cellLayout & TTLiveCellLayoutBubbleCoverTop) ? _isReplyedMsg ? 0 : PaddingContentTopAndBottom() : 0,
                                    (_isReplyedMsg ? CGRectGetWidth(self.frame) : TopInfoViewWidth(self.message.cellLayout)),
                                    _isReplyedMsg ? HeightOfTopInfoViewByReply() :  kLivePaddingCellTopInfoViewHeight(_message.cellLayout));
    if (!_isIncomingMsg) {
        _topInfoView.right = CGRectGetWidth(self.frame);
    }
}

- (void)showContentWithMessage:(TTLiveMessage *)message isIncomingMsg:(BOOL)isIncoming
{
    self.message = message;
    self.isReplyedMsg = message.isReplyedMsg;
    self.isIncomingMsg = isIncoming;
    
    [self.topInfoView setupInfoWithMessage:message isIncomingMsg:isIncoming];
}

@end
