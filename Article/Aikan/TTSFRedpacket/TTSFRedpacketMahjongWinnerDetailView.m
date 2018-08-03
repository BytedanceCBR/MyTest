//
//  TTSFRedpacketMahjongWinnerDetailView.m
//  Article
//
//  Created by chenjiesheng on 2017/12/3.
//  麻将胡牌红包，带小视频样式

#import "TTSFRedpacketMahjongWinnerDetailView.h"
#import <ExploreAvatarView.h>
#import "TTSFTracker.h"

@interface TTSFRedpacketMahjongWinnerDetailView ()

@property (nonatomic, copy) NSString *sponsorWebURLString;

@end

@implementation TTSFRedpacketMahjongWinnerDetailView

- (void)layoutSubviews
{
    [super layoutSubviews];    
}

- (void)configWithViewModel:(TTRedPacketDetailBaseViewModel *)viewModel
{
    [super configWithViewModel:viewModel];
    
    if ([viewModel isKindOfClass:[TTSFRedpacketDetailViewModel class]]) {
        TTSFRedpacketDetailViewModel *sfViewModel = (TTSFRedpacketDetailViewModel *)viewModel;
        _sponsorWebURLString = sfViewModel.sponsor.url;
        
        self.playVideo.hidden = NO;
        self.playVideoBgView.hidden = NO;
        [self.playVideo.player readyToPlay];
        [self.playVideo.player play];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        self.nameLabel.userInteractionEnabled = YES;
        [self.nameLabel addGestureRecognizer:tapGesture];
        
        UITapGestureRecognizer *tapGestureOnImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        self.avatarView.userInteractionEnabled = YES;
        self.avatarView.imageView.userInteractionEnabled = YES;
        [self.avatarView.imageView addGestureRecognizer:tapGestureOnImage];
        
        UITapGestureRecognizer *tapGestureOnVideo = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        self.playVideo.userInteractionEnabled = YES;
        [self.playVideo addGestureRecognizer:tapGestureOnVideo];
    }
    
    [self layoutSubviews];
}

- (void)tap:(id)sender
{
    NSURL *url = [NSURL URLWithString:_sponsorWebURLString];
    if ([[TTRoute sharedRoute] canOpenURL:url]) {
        [[TTRoute sharedRoute] openURLByPushViewController:url];
    }
    
    [TTSFTracker event:@"red_env_sponsor_click"
             eventType:TTSpringActivityEventTypeMahjong
                params:({
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setValue:self.rpViewModel.sponsor.ID.stringValue forKey:@"sponsor_id"];
        [params copy];
    })];
}

- (void)redPacketDidFinishTransitionAnimation
{
    self.playVideo.hidden = NO;
    self.playVideoBgView.hidden = NO;
}

@end
