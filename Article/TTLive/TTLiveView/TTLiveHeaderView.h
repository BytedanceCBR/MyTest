//
//  TTLiveHeaderView.h
//  TTLive
//
//  Created by matrixzk on 7/17/16.
//
//

#import <UIKit/UIKit.h>

#import "TTLiveTopBannerInfoModel.h"
#import "TTLiveMainViewController.h"

//#import "SSThemed.h"
//#import "TTImageView.h"

@class TTLiveStreamDataModel, TTImageView;

@interface TTLiveHeaderView : UIView

@property (nonatomic, weak, readonly) TTLiveMainViewController *chatroom;
@property (nonatomic, strong, readonly)  TTLiveTopBannerInfoModel *dataModel;

@property (nonatomic, assign) TTLiveStatus currentLiveStatus;
@property (nonatomic, strong) UIButton *numOfParticipantsView;
@property (nonatomic, strong) UIButton *statusView;
//@property (nonatomic, strong) SSThemedButton *numOfParticipantsView;
//@property (nonatomic, strong) SSThemedButton *statusView;

@property (nonatomic, strong) TTImageView *backgroundImageView;
@property (nonatomic, assign) CGFloat heightOffset;



- (instancetype)initWithFrame:(CGRect)frame dataModel:(TTLiveTopBannerInfoModel *)model chatroom:(TTLiveMainViewController *)chatroom heightOffset:(CGFloat)heightOffset;

/// Refresh HeaderView
- (void)refreshHeaderViewWithModel:(TTLiveStreamDataModel *)model;

//- (void)stopVideo;
//- (void)playVideo;

/// for category
- (SSThemedLabel *)labelWithColorKey:(NSString *)colorKey fontSize:(CGFloat)fontSize;
- (void)refreshStatusViewWithModel:(TTLiveStreamDataModel *)model;

@end
