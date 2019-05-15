//
//  ExploreAddEntryListCell.m
//  Article
//
//  Created by Zhang Leonardo on 14-11-23.
//
//

#import "ExploreAddEntryListCell.h"
//#import "UILabel+TrueRectUsing.h"
#import "UIImageView+WebCache.h"
#import "ExploreEntryManager.h"
#import "TTDeviceHelper.h"
#import "FriendDataManager.h"

#define kTopMargin 15
#define kChannelListIconImageWidth          36
#define kChannelListIconImageHeight         36
#define kChannelListIconImageCornerRadius   5

#define kSubscribeButtonWidth   54
#define kSubscribeButtonHeight  28

@interface ExploreAddEntryListCell ()
{
    BOOL _isEntrySubscribed;
}

@property (nonatomic, strong) UIView *bottomDivideLineView;

@end


@implementation ExploreAddEntryListCell

+ (CGFloat)defaultHeight
{
    return 66;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.imageLeftPadding = 15;
        self.buttonRightPadding = 15;
        self.bottomLineLeftPadding = 15;
        self.bottomLineRightPadding = 15;
        
        self.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        
        self.channelImageView = [[TTImageView alloc] initWithFrame:CGRectMake(0, 0, kChannelListIconImageWidth, kChannelListIconImageHeight)];
        _channelImageView.backgroundColorThemeKey = kColorBackground2;
        _channelImageView.layer.cornerRadius = kChannelListIconImageCornerRadius;
        _channelImageView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        _channelImageView.layer.borderColor = [[UIColor colorWithHexString:@"dddddd"] CGColor];
        _channelImageView.clipsToBounds = YES;
        [self.contentView addSubview:_channelImageView];
        
        self.channelNameLabel = [[UILabel alloc] init];
        self.channelNameLabel.backgroundColor = [UIColor clearColor];
        _channelNameLabel.font = [UIFont boldSystemFontOfSize:15];
        _channelNameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:_channelNameLabel];
        
        self.detailLabel = [[UILabel alloc] init];
        self.detailLabel.backgroundColor = [UIColor clearColor];
        _detailLabel.font = [UIFont systemFontOfSize:10];
        _detailLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:_detailLabel];
        
        self.subscribeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_subscribeButton setFrame:CGRectMake(0, 0, kSubscribeButtonWidth, kSubscribeButtonHeight)];
        [_subscribeButton addTarget:self action:@selector(subscribeChannel) forControlEvents:UIControlEventTouchUpInside];
        _subscribeButton.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        _subscribeButton.titleLabel.font = [UIFont systemFontOfSize:12.f];
        _subscribeButton.layer.cornerRadius = 5.f;
        [self.contentView addSubview:self.subscribeButton];
        
        self.bottomDivideLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 0.5f)];
        [self.contentView addSubview:_bottomDivideLineView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(followNotification:) name:RelationActionSuccessNotification object:nil];
        
        [self themeChanged:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.cellDelegate = nil;
}

- (void)themeChanged:(NSNotification *)notification
{
    self.selectedBackgroundView.backgroundColor = [UIColor colorWithDayColorName:@"fafafa" nightColorName:@"252525"];
    self.contentView.backgroundColor = [UIColor colorWithDayColorName:@"fafafa" nightColorName:@"252525"];
//    self.backgroundView.backgroundColor = [UIColor colorWithHexString:@"#ffffff"];
    _channelNameLabel.textColor = [UIColor colorWithHexString:@"505050"];
    _detailLabel.textColor = [UIColor colorWithHexString:@"999999"];
    
    [self refreshSubscribeButton];
    
    _bottomDivideLineView.backgroundColor = [UIColor colorWithDayColorName:@"f2f2f2" nightColorName:@"303030"];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _channelImageView.frame = CGRectMake(self.imageLeftPadding, kTopMargin, _channelImageView.frame.size.width, _channelImageView.frame.size.height);
    
    self.subscribeButton.center = CGPointMake(CGRectGetWidth(self.bounds)-self.buttonRightPadding-CGRectGetWidth(self.subscribeButton.frame)/2, CGRectGetMidY(self.bounds));
    
    CGFloat labelMaxWidth = CGRectGetMinX(self.subscribeButton.frame)-CGRectGetMaxX(_channelImageView.frame)-10-10;
    CGRect labelFrame = CGRectZero;
    labelFrame.origin = CGPointMake(CGRectGetMaxX(_channelImageView.frame)+10, CGRectGetMinY(_channelImageView.frame));
    labelFrame.size = CGSizeMake(labelMaxWidth, CGFLOAT_MAX);
    _channelNameLabel.frame = [_channelNameLabel textRectForBounds:labelFrame limitedToNumberOfLines:1];
    
    labelFrame.origin = CGPointMake(CGRectGetMaxX(_channelImageView.frame)+10, CGRectGetMaxY(_channelNameLabel.frame)+4);
    labelFrame.size = CGSizeMake(labelMaxWidth, CGFLOAT_MAX);
    _detailLabel.frame = [_detailLabel textRectForBounds:labelFrame limitedToNumberOfLines:1];
    
    _bottomDivideLineView.frame = CGRectMake(self.bottomLineLeftPadding, CGRectGetMaxY(self.bounds)-[TTDeviceHelper ssOnePixel], CGRectGetWidth(self.bounds)-self.bottomLineLeftPadding-self.bottomLineRightPadding, [TTDeviceHelper ssOnePixel]);
}

- (void)fillWithChannelInfo:(ExploreEntry *)channelInfo
{
    self.channelInfo = channelInfo;
    _channelNameLabel.text = channelInfo.name;
    _detailLabel.text = channelInfo.desc;
    
    [_channelImageView setImageWithURLString:channelInfo.imageURLString placeholderImage:nil];
    [self setSubscribed:[channelInfo.subscribed boolValue]];
}

- (void)subscribeChannel
{
    if (_isEntrySubscribed) {
        if(_cellDelegate && [_cellDelegate respondsToSelector:@selector(channelListCell:unsubscribeChannel:)]) {
            [_cellDelegate channelListCell:self unsubscribeChannel:_channelInfo];
        }
        wrapperTrackEventWithCustomKeys(@"subscription", @"unsubscribe", self.channelInfo.mediaID.stringValue, nil, nil);
    }
    else {
        if(_cellDelegate && [_cellDelegate respondsToSelector:@selector(channelListCell:subscribeChannel:)]) {
            [_cellDelegate channelListCell:self subscribeChannel:_channelInfo];
        }
        wrapperTrackEventWithCustomKeys(@"subscription", @"subscribe", self.channelInfo.mediaID.stringValue, nil, nil);
    }
    
    [self fillWithChannelInfo:self.channelInfo];
}

- (void)setSubscribed:(BOOL)isSubscribed
{
    _isEntrySubscribed = isSubscribed;
    [self refreshSubscribeButton];
}

- (void)refreshSubscribeButton
{
    if (_isEntrySubscribed) {
        [_subscribeButton setTitle:@"已关注" forState:UIControlStateNormal];
        _subscribeButton.layer.borderColor = [UIColor colorWithDayColorName:@"999999" nightColorName:@"505050"].CGColor;
        [_subscribeButton setTitleColor:[UIColor colorWithDayColorName:@"999999" nightColorName:@"505050"] forState:UIControlStateNormal];
        [_subscribeButton setTitleColor:[UIColor colorWithDayColorName:@"cacaca" nightColorName:@"363636"] forState:UIControlStateHighlighted];
    }
    else {
        [_subscribeButton setTitle:@"关注" forState:UIControlStateNormal];
        _subscribeButton.layer.borderColor = [[UIColor colorWithDayColorName:@"2a90d7" nightColorName:@"67778b"] CGColor];
        [_subscribeButton setTitleColor:[UIColor colorWithDayColorName:@"2a90d7" nightColorName:@"67778b"] forState:UIControlStateNormal];
        [_subscribeButton setTitleColor:[UIColor colorWithDayColorName:@"a7c9e9" nightColorName:@"4d5866"] forState:UIControlStateHighlighted];
    }
}

- (void)followNotification:(NSNotification *)notify
{
    NSString *userID = notify.userInfo[kRelationActionSuccessNotificationUserIDKey];
    NSString *currentUserID = [NSString stringWithFormat:@"%@", self.channelInfo.userID];
    if (!isEmptyString(userID) && [userID isEqualToString:currentUserID]) {
        NSInteger actionType = [(NSNumber *)notify.userInfo[kRelationActionSuccessNotificationActionTypeKey] integerValue];
        if (actionType == FriendActionTypeFollow) {
            self.channelInfo.subscribed = @YES;
            [self setSubscribed:YES];
        }else if (actionType == FriendActionTypeUnfollow) {
            self.channelInfo.subscribed = @NO;
            [self setSubscribed:NO];
        }
    }
}

@end
