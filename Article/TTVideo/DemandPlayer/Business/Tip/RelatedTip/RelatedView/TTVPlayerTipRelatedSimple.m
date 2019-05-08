//
//  TTVPlayerTipRelatedSimple.m
//  Article
//
//  Created by panxiang on 2017/10/12.
//

#import "TTVPlayerTipRelatedSimple.h"
#import "NSTimer+NoRetain.h"

@interface TTVPlayerTipRelatedSimple()
@property (nonatomic ,strong)UIButton *button;
@property (nonatomic ,strong)UILabel *titleLabel;
@property (nonatomic ,strong)UIImageView *arrowImageView;
@property (nonatomic ,strong)NSTimer *timer;
@property (nonatomic ,strong)TTVPlayerTipRelatedEntity *entity;
@end

@implementation TTVPlayerTipRelatedSimple
- (void)dealloc
{
    [self.timer invalidate];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.button addTarget:self action:@selector(clickAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.button];

        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:[TTDeviceUIUtils tt_fontSize:13]] ? : [UIFont boldSystemFontOfSize:[TTDeviceUIUtils tt_fontSize:13]];
        _titleLabel.numberOfLines = 1;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:_titleLabel];
        
        _arrowImageView = [[UIImageView alloc] init];
        _arrowImageView.image = [UIImage imageNamed:@"video_tip_related_arrow.png"];
        _arrowImageView.backgroundColor = [UIColor clearColor];
        [_arrowImageView sizeToFit];
        [self addSubview:_arrowImageView];
    }
    return self;
}

- (void)timeChange
{
    static int time = 0;
    int index = time % (self.entitys.count - 1);
    if (index <= self.entitys.count - 1) {
        TTVPlayerTipRelatedEntity *entity = [self.entitys objectAtIndex:index];
        [self sendShowTrack:self.entity];
        [self refreshUIWithEntity:entity];
    }
    time++;
    if (time >= INT_MAX) {
        time = 0;
    }
    [self setNeedsLayout];
}

- (void)setEntitys:(NSMutableArray<TTVPlayerTipRelatedEntity *> *)entitys
{
    [super setEntitys:entitys];
    TTVPlayerTipRelatedEntity *entity = [entitys firstObject];
    [self refreshUIWithEntity:entity];
}

- (void)refreshUIWithEntity:(TTVPlayerTipRelatedEntity *)entity
{
    self.entity = entity;
    if (!isEmptyString(entity.title)) {
        _titleLabel.text = [NSString stringWithFormat:@"%@ | %@",isEmptyString(entity.download_text) ? @"查看更多" : entity.download_text ,entity.title];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat height = 18;
    CGFloat top = (self.height - height) / 2.0;
    _arrowImageView.frame = CGRectMake(self.width - _arrowImageView.width - 3, (self.height - _arrowImageView.height) / 2.0, _arrowImageView.width, _arrowImageView.height);
    [_titleLabel sizeToFit];
    _titleLabel.frame = CGRectMake(15, top, _arrowImageView.left - 41, height);
    self.button.frame = self.bounds;
}

- (void)clickAction
{
    [self openDownloadUrl:self.entity];
}

- (void)sendShowTrack:(TTVPlayerTipRelatedEntity *)entity
{
    if (!entity.hasSendShowTrack.boolValue) {
        if ([self.delegate respondsToSelector:@selector(relatedViewSendShowTrack:)]) {
            [self.delegate relatedViewSendShowTrack:entity];
            entity.hasSendShowTrack = [NSNumber numberWithBool:YES];
        }
    }
}

- (void)startTimer
{
    [self performSelector:@selector(sendShowTrack:) withObject:self.entity afterDelay:0];
    [self.timer invalidate];
    self.timer = [NSTimer scheduledNoRetainTimerWithTimeInterval:kAutoChangeTime target:self selector:@selector(timeChange) userInfo:nil repeats:YES];
}

- (void)pauseTimer
{
    __unused __strong typeof(self) strongSelf = self;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(sendShowTrack:) object:self.entity];
    [self.timer invalidate];
    self.timer = nil;
}
@end
