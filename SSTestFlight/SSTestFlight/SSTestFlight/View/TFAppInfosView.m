//
//  TFAppInfosView.m
//  SSTestFlight
//
//  Created by Zhang Leonardo on 13-5-29.
//  Copyright (c) 2013年 Leonardo. All rights reserved.
//

#import "TFAppInfosView.h"
#import "UIColorAdditions.h"
#import "SSLazyImageView.h"
#import "SSPrivateUtil.h"

#define contentLeftMargin 10.f
#define contentRightMargin 20.f
#define contentTopMargin 20.f
#define contentBottomMargin 20.f

#define ItemServicesURLStr @"itms-services://?action=download-manifest&url="
#define DownloadURLStr @"http%%3A//admin.bytedance.com/apptest/get_manifest/%%3Frelease_id%%3D%@%%26ipa_hash%%3D%@"

typedef enum TFAppStatusType{
    TFAppStatusTypeNeedIntall,
    TFAppStatusTypeNeedUpdate,
    TFAppStatusTypeIsNewest
}TFAppStatusType;

@interface TFAppInfosView()
@property(nonatomic, retain)SSLazyImageView * iconImageView;
@property(nonatomic, retain)UILabel * indexLabel;
@property(nonatomic, retain)UILabel * appNameLabel;
@property(nonatomic, retain)UILabel * versionLabel;
@property(nonatomic, retain)UIButton * installButton;
@property(nonatomic, retain)UILabel * timeLabel;
@property(nonatomic, retain)TFAppInfosModel * model;

@end

@implementation TFAppInfosView

+ (CGFloat)heightForCellWithModel:(TFAppInfosModel *)model cellWidth:(CGFloat)width
{
    return 90.f;
}

- (void)dealloc
{
    self.timeLabel = nil;
    self.bgButton = nil;
    self.model = nil;
    self.installButton = nil;
    self.versionLabel = nil;
    self.indexLabel = nil;
    self.iconImageView = nil;
    self.appNameLabel = nil;
    [super dealloc];
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self buildView];
    }
    return self;
}



- (void)buildView
{
    self.backgroundColor = [UIColor clearColor];
//    UIView * bgView = [[UIView alloc] initWithFrame:self.bounds];
//    bgView.backgroundColor = [UIColor clearColor];
//    self.selectedBackgroundView = bgView;
//    [bgView release];
    
    self.bgButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _bgButton.frame = self.bounds;
    setAutoresizingMaskFlexibleWidthAndHeight(_bgButton);
    [self addSubview:_bgButton];
    
    self.iconImageView = [[[SSLazyImageView alloc] initWithFrame:[self frameForIconView]] autorelease];
    _iconImageView.backgroundColor = [UIColor clearColor];
    [self addSubview:_iconImageView];
    
    self.indexLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
    [_indexLabel setText:@"  "];
    _indexLabel.backgroundColor = [UIColor clearColor];
    [_indexLabel setFont:[UIFont boldSystemFontOfSize:25.f]];
    [_indexLabel setTextColor:[UIColor colorWithHexString:@"999999"]];
    [self addSubview:_indexLabel];
    
    self.appNameLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
    _appNameLabel.backgroundColor = [UIColor clearColor];
    _appNameLabel.font = [UIFont boldSystemFontOfSize:15.f];
    _appNameLabel.textColor = [UIColor colorWithHexString:@"333333"];
    [self addSubview:_appNameLabel];
    
    self.versionLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
    _versionLabel.backgroundColor = [UIColor clearColor];
    _versionLabel.font = [UIFont systemFontOfSize:12.f];
    _versionLabel.textColor = [UIColor colorWithHexString:@"666666"];
    [self addSubview:_versionLabel];
    
    self.installButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _installButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.f];
    _installButton.layer.cornerRadius = 5.f;
    [_installButton addTarget:self action:@selector(installButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    _installButton.backgroundColor = [UIColor colorWithHexString:SSUIString(@"projectBasicUIColor", @"77157d")];
    [self addSubview:_installButton];
    
    self.timeLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
    _timeLabel.backgroundColor = [UIColor clearColor];
    _timeLabel.font = [UIFont systemFontOfSize:12.f];
    _timeLabel.textColor = [UIColor colorWithHexString:@"666666"];
    [self addSubview:_timeLabel];
    
    [self refreshFrame];
    [self refreshInstallButton];
    [self refreshVersionLabel];
    
}


- (void)installButtonClicked
{
    if (_model.ipaHash == nil || _model.releaseID == nil) {
        SSLog(@"model参数错误");
        return;
    }
#warning fix here
//    if ([self checkAppStatus] == TFAppStatusTypeIsNewest) {
//        //do nothing...
//    }
//    else {
        NSString * downURLStr = [NSString stringWithFormat:DownloadURLStr, _model.releaseID, _model.ipaHash];
        NSString * urlStr = [NSString stringWithFormat:@"%@%@", ItemServicesURLStr, downURLStr];
        NSURL * url = [NSURL URLWithString:urlStr];
        [[UIApplication sharedApplication] openURL:url];
        
//    }
}

- (void)setAppInfosModel:(TFAppInfosModel *)model modelIndex:(NSUInteger)row
{
    self.model = model;    
    _indexLabel.text = [NSString stringWithFormat:@"%i", row];
    [_iconImageView setNetImageUrl:model.iconURL];
    _appNameLabel.text = [NSString stringWithFormat:@"%@", model.appName];
    NSString * time = [SSCommon noTimeStringSince1970:[_model.uploadTime doubleValue]];
    _timeLabel.text = time;
    
    [self refreshFrame];
    [self refreshInstallButton];
    
}

- (void)refreshFrame
{
    _indexLabel.frame = [self frameForIndexLabel];
    _iconImageView.frame = [self frameForIconView];
    _appNameLabel.frame = [self frameForAppNameLabel];
    [self refreshVersionLabel];
    _timeLabel.frame = [self frameForTimeLabel];
}

- (void)refreshVersionLabel
{
    
    if ([self checkAppStatus] != TFAppStatusTypeNeedUpdate) {
        _versionLabel.text = [NSString stringWithFormat:@"%@", _model.versionName];
    }
    else {
        _versionLabel.text = [NSString stringWithFormat:@"%@ 更新至 %@", [SSPrivateUtil appBundleVersionIfInstalled:_model.pkgName], _model.versionName];
    }
    
    _versionLabel.frame = [self frameForVersionLabel];
}

- (void)refreshInstallButton
{
    NSString * buttonBgName = nil;
    NSString * buttonBgPressName = nil;
    switch ([self checkAppStatus]) {
        case TFAppStatusTypeNeedIntall:
        {
            [_installButton setTitle:@"安装" forState:UIControlStateNormal];
        }
            break;
        case TFAppStatusTypeNeedUpdate:
        {
            [_installButton setTitle:@"更新" forState:UIControlStateNormal];
        }
            break;
        case TFAppStatusTypeIsNewest:
        {
            [_installButton setTitle:@"已安装" forState:UIControlStateNormal];
        }
        default:
            break;
    }
    
    UIImage *normalBackgroundImage = [UIImage resourceImageNamed:buttonBgName];
    normalBackgroundImage = [normalBackgroundImage stretchableImageWithLeftCapWidth:normalBackgroundImage.size.width/2
                                                                       topCapHeight:normalBackgroundImage.size.height/2];
    [_installButton setBackgroundImage:normalBackgroundImage forState:UIControlStateNormal];
    
    UIImage *highBackgroundImage = [UIImage resourceImageNamed:buttonBgPressName];
    highBackgroundImage = [highBackgroundImage stretchableImageWithLeftCapWidth:highBackgroundImage.size.width/2
                                                                   topCapHeight:highBackgroundImage.size.height/2];
    [_installButton setBackgroundImage:highBackgroundImage forState:UIControlStateNormal];
    
    _installButton.frame = [self frameForInstallButton];
}

- (TFAppStatusType)checkAppStatus
{
    return TFAppStatusTypeNeedIntall;
//    BOOL appInstalled = [SSPrivateUtil isAppInstalled:_model.pkgName];
//    if (!appInstalled) {
//        return TFAppStatusTypeNeedIntall;
//    }
//    else {
//        return TFAppStatusTypeIsNewest;
//        NSString * installedVersion = [SSPrivateUtil appBundleVersionIfInstalled:_model.pkgName];
//        BOOL needUpdate = [TFAppInfosView checkNeedUpdate:_model.versionName currentInstallVersion:installedVersion];
//        if (needUpdate) {
//            return TFAppStatusTypeNeedUpdate;
//        }
//        else {
//            return TFAppStatusTypeIsNewest;
//        }
//    }
}

+ (BOOL)checkNeedUpdate:(NSString *)modelVersion currentInstallVersion:(NSString *)currentVersion
{
    BOOL hasNewVersion = NO;  // true means has new version
    
    if ([modelVersion length] == 0) return NO;
    if ([currentVersion length] == 0) {
        return YES;
    }
    
    NSArray *currentVersionArray = [currentVersion componentsSeparatedByString:@"."];
    NSArray *lastVersionArray = [modelVersion componentsSeparatedByString:@"."];
    
    int currentPosition = 0;
    while (!hasNewVersion && (currentPosition < [currentVersionArray count] || currentPosition < [lastVersionArray count])) {
        
        int currentPositionValue = currentPosition < [currentVersionArray count] ?
        [[currentVersionArray objectAtIndex:currentPosition] intValue] :
        0;
        int lastPositionValue = currentPosition < [lastVersionArray count] ?
        [[lastVersionArray objectAtIndex:currentPosition] intValue] :
        0;
        
        hasNewVersion = lastPositionValue > currentPositionValue;
        
        if (lastPositionValue < currentPositionValue) {
            break;
        }
        
        currentPosition ++;
    }
    
    return hasNewVersion;
}

#pragma mark -- frame

- (CGFloat)heightForSelf
{
    return [TFAppInfosView heightForCellWithModel:_model cellWidth:self.frame.size.width];
}

- (CGRect)frameForInstallButton
{
    CGRect rect = CGRectMake(self.frame.size.width - 44 - contentRightMargin, ([self heightForSelf] - 30) / 2.f, 44, 30);
    return rect;
}

- (CGRect)frameForVersionLabel
{
    [_versionLabel sizeToFit];
    CGRect rect = _versionLabel.frame;
    rect.origin.x = CGRectGetMinX([self frameForAppNameLabel]);
    rect.origin.y = CGRectGetMaxY([self frameForAppNameLabel]) + 3;
    return rect;
}

- (CGRect)frameForTimeLabel
{
    [_timeLabel sizeToFit];
    CGRect rect = CGRectMake(CGRectGetMaxX([self frameForIconView]) + 10, CGRectGetMaxY([self frameForVersionLabel]) + 3, _timeLabel.frame.size.width, _timeLabel.frame.size.height);
    return rect;
}

- (CGRect)frameForAppNameLabel
{
    [_appNameLabel sizeToFit];
    CGRect rect = CGRectMake(CGRectGetMaxX([self frameForIconView]) + 10, CGRectGetMinY([self frameForIconView]), _appNameLabel.frame.size.width, _appNameLabel.frame.size.height);
    return rect;
}

- (CGRect)frameForIconView
{
    CGRect rect = CGRectMake(CGRectGetMaxX([self frameForIndexLabel]) + 20, contentTopMargin, 50, 50);
    return rect;
}

- (CGRect)frameForIndexLabel
{
    [_indexLabel sizeToFit];
    return CGRectMake(contentLeftMargin, ([self heightForSelf] - 30) / 2.f, _indexLabel.frame.size.width, _indexLabel.frame.size.height);
}

@end
