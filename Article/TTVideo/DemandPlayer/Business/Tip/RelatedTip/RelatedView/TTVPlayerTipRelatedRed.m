//
//  TTVPlayerTipRelatedRed.m
//  Article
//
//  Created by panxiang on 2017/10/12.
//

#import "TTVPlayerTipRelatedRed.h"
#import "NSTimer+NoRetain.h"

@interface TTVPlayerTipRelatedRed()
@property (nonatomic ,strong)UIButton *button;
@property (nonatomic ,strong)UILabel *titleLabel;
@property (nonatomic ,strong)UIImageView *arrowImageView;
@property (nonatomic ,strong)NSTimer *timer;
@property (nonatomic ,strong)TTVPlayerTipRelatedEntity *entity;

@end

@implementation TTVPlayerTipRelatedRed
- (void)dealloc
{
    [self.timer invalidate];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
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
        
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.button addTarget:self action:@selector(clickAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.button];
    }
    return self;
}

- (void)timeChange
{
    [UIView animateWithDuration:0.3 animations:^{
        self.backgroundColor = [UIColor colorWithRed:248/255.0f green:89/255.0f blue:89/255.0f alpha:1];
    }];
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

- (void)setEntitys:(NSMutableArray<TTVPlayerTipRelatedEntity *> *)entitys
{
    [super setEntitys:entitys];
    NSInteger index = rand();
    TTVPlayerTipRelatedEntity *entity = nil;
    if (entitys.count > 0) {
        entity = [entitys objectAtIndex:index % entitys.count];
    }
    if (!isEmptyString(entity.title)) {
        _titleLabel.text = [NSString stringWithFormat:@"%@ | %@",isEmptyString(entity.download_text) ? @"查看更多" : entity.download_text ,entity.title];
    }
    self.entity = entity;
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

- (void)startTimer
{
    [self performSelector:@selector(sendShowTrack:) withObject:self.entity afterDelay:0];
    [self.timer invalidate];
    self.timer = [NSTimer scheduledNoRetainTimerWithTimeInterval:1 target:self selector:@selector(timeChange) userInfo:nil repeats:NO];
}

- (void)pauseTimer
{
    __unused __strong typeof(self) strongSelf = self;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(sendShowTrack:) object:self.entity];
    [self.timer invalidate];
    self.timer = nil;
}

- (void)clickAction
{
    [self openDownloadUrl:self.entity];
}

@end

