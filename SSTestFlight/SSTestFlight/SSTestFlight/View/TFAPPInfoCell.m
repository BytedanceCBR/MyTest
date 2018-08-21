//
//  TFAPPInfoCell.m
//  SSTestFlight
//
//  Created by Zhang Leonardo on 13-5-28.
//  Copyright (c) 2013年 Leonardo. All rights reserved.
//

#import "TFAPPInfoCell.h"
#import "TFAppInfosView.h"
#import "UIColorAdditions.h"

@interface TFAPPInfoCell()

@property(nonatomic, retain)TFAppInfosView * infosView;
//@property(nonatomic, retain)UIButton * bgButton;
@property(nonatomic, retain)TFAppInfosModel * model;
@property(nonatomic, assign)NSUInteger cellIndex;
@end

@implementation TFAPPInfoCell

- (void)dealloc
{
    self.model = nil;
    self.delegate = nil;
//    self.bgButton = nil;
    self.infosView = nil;
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
//        self.bgButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        _bgButton.frame = self.bounds;
//        setAutoresizingMaskFlexibleWidthAndHeight(_bgButton);
//        [_bgButton addTarget:self action:@selector(bgButtonClicked) forControlEvents:UIControlEventTouchUpInside];
//        [self.contentView addSubview:_bgButton];

        
        self.infosView = [[[TFAppInfosView alloc] initWithFrame:self.bounds] autorelease];
        [_infosView.bgButton addTarget:self action:@selector(bgButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        setAutoresizingMaskFlexibleWidthAndHeight(_infosView);
        [self.contentView addSubview:_infosView];
    }
    return self;
}

- (void)bgButtonClicked
{
    NSLog(@"bgButtonClicked");
    if (_delegate && [_delegate respondsToSelector:@selector(tableViewCellDidSelectedBackgroundButton:selectedModel:selectedIndex:)]) {
        [_delegate tableViewCellDidSelectedBackgroundButton:self selectedModel:_model selectedIndex:_cellIndex];
    }
}


- (void)setAppInfosModel:(TFAppInfosModel *)model modelIndex:(NSUInteger)row
{
    self.cellIndex = row;
    self.model = model;
    if (row % 2 == 0) {
        self.contentView.backgroundColor = [UIColor colorWithHexString:@"eeeeee"];
    }
    else {
        self.contentView.backgroundColor = [UIColor colorWithHexString:@"dddddd"];
    }

    [_infosView setAppInfosModel:model modelIndex:row];
}

+ (CGFloat)heightForCellWithModel:(TFAppInfosModel *)model cellWidth:(CGFloat)width
{
    return [TFAppInfosView heightForCellWithModel:model cellWidth:width];
}

@end

//#import "TFAPPInfoCell.h"
//#import "UIColorAdditions.h"
//#import "SSLazyImageView.h"
//#import "SSPrivateUtil.h"
//
//#define contentLeftMargin 10.f
//#define contentRightMargin 20.f
//#define contentTopMargin 20.f
//#define contentBottomMargin 20.f
//
//#define ItemServicesURLStr @"itms-services://?action=download-manifest&url="
//#define DownloadURLStr @"http%%3A//dev.bytedance.com%%3A4188/apptest/get_manifest/%%3Frelease_id%%3D%@%%26ipa_hash%%3D%@"
//
//typedef enum TFAppStatusType{
//    TFAppStatusTypeNeedIntall,
//    TFAppStatusTypeNeedUpdate,
//    TFAppStatusTypeIsNewest
//}TFAppStatusType;
//
//@interface TFAPPInfoCell()
//@property(nonatomic, retain)SSLazyImageView * iconImageView;
//@property(nonatomic, retain)UILabel * indexLabel;
//@property(nonatomic, retain)UILabel * appNameLabel;
//@property(nonatomic, retain)UILabel * versionLabel;
//@property(nonatomic, retain)UIButton * installButton;
//@property(nonatomic, retain)TFAppInfosModel * model;
//@property(nonatomic, retain)UIButton * bgButton;
//@end
//
//@implementation TFAPPInfoCell
//
//+ (CGFloat)heightForCellWithModel:(TFAppInfosModel *)model cellWidth:(CGFloat)width
//{
//    return 90.f;
//}
//
//- (void)dealloc
//{
//    self.bgButton = nil;
//    self.model = nil;
//    self.installButton = nil;
//    self.versionLabel = nil;
//    self.indexLabel = nil;
//    self.iconImageView = nil;
//    self.appNameLabel = nil;
//    [super dealloc];
//}
//
//
//- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
//{
//    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
//    if (self) {
//        [self buildView];
//    }
//    return self;
//}
//
//
//
//- (void)buildView
//{
//    UIView * bgView = [[UIView alloc] initWithFrame:self.bounds];
//    bgView.backgroundColor = [UIColor clearColor];
//    self.selectedBackgroundView = bgView;
//    [bgView release];
//    
//    self.bgButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    _bgButton.frame = self.bounds;
//    setAutoresizingMaskFlexibleWidthAndHeight(_bgButton);
//    [_bgButton addTarget:self action:@selector(bgButtonClicked) forControlEvents:UIControlEventTouchUpInside];
//    [self.contentView addSubview:_bgButton];
//    
//    self.iconImageView = [[[SSLazyImageView alloc] initWithFrame:[self frameForIconView]] autorelease];
//    _iconImageView.backgroundColor = [UIColor clearColor];
//    [self.contentView addSubview:_iconImageView];
//    
//    self.indexLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
//    [_indexLabel setText:@"  "];
//    _indexLabel.backgroundColor = [UIColor clearColor];
//    [_indexLabel setFont:[UIFont boldSystemFontOfSize:25.f]];
//    [_indexLabel setTextColor:[UIColor colorWithHexString:@"999999"]];
//    [self addSubview:_indexLabel];
//    
//    self.appNameLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
//    _appNameLabel.backgroundColor = [UIColor clearColor];
//    _appNameLabel.font = [UIFont boldSystemFontOfSize:15.f];
//    _appNameLabel.textColor = [UIColor colorWithHexString:@"333333"];
//    [self addSubview:_appNameLabel];
//    
//    self.versionLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
//    _versionLabel.backgroundColor = [UIColor clearColor];
//    _versionLabel.font = [UIFont systemFontOfSize:12.f];
//    _versionLabel.textColor = [UIColor colorWithHexString:@"666666"];
//    [self addSubview:_versionLabel];
//    
//    self.installButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    _installButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.f];
//    _installButton.backgroundColor = [UIColor clearColor];
//    [_installButton addTarget:self action:@selector(installButtonClicked) forControlEvents:UIControlEventTouchUpInside];
//    [self addSubview:_installButton];
//
//    [self refreshFrame];
//    [self refreshInstallButton];
//    [self refreshVersionLabel];
//}
//
//- (void)bgButtonClicked
//{
//    NSLog(@"bgButtonClicked");
//}
//
//- (void)installButtonClicked
//{
//    if (_model.ipaHash == nil || _model.releaseID == nil) {
//        SSLog(@"model参数错误");
//        return;
//    }
//    if ([self checkAppStatus] == TFAppStatusTypeIsNewest) {
//        //do nothing...
//    }
//    else {
//        NSString * downURLStr = [NSString stringWithFormat:DownloadURLStr, _model.releaseID, _model.ipaHash];
//        NSString * urlStr = [NSString stringWithFormat:@"%@%@", ItemServicesURLStr, downURLStr];
//        NSURL * url = [NSURL URLWithString:urlStr];
//        [[UIApplication sharedApplication] openURL:url];
//
//    }
//}
//
//- (void)setAppInfosModel:(TFAppInfosModel *)model modelIndex:(NSUInteger)row
//{
//    self.model = model;
//    if (row % 2 == 0) {
//        self.contentView.backgroundColor = [UIColor colorWithHexString:@"eeeeee"];
//    }
//    else {
//        self.contentView.backgroundColor = [UIColor colorWithHexString:@"bbbbbb"];
//    }
//    
//    _indexLabel.text = [NSString stringWithFormat:@"%i", row];
//    [_iconImageView setNetImageUrl:model.iconURL];
//    _appNameLabel.text = [NSString stringWithFormat:@"%@", model.appName];
//    
//    
//    [self refreshFrame];
//    [self refreshInstallButton];
//    [self refreshVersionLabel];
//}
//
//- (void)refreshFrame
//{
//    _indexLabel.frame = [self frameForIndexLabel];
//    _iconImageView.frame = [self frameForIconView];
//    _appNameLabel.frame = [self frameForAppNameLabel];
//    
//}
//
//- (void)refreshVersionLabel
//{
//    
//    if ([self checkAppStatus] != TFAppStatusTypeNeedUpdate) {
//        _versionLabel.text = [NSString stringWithFormat:@"%@", _model.versionName];
//    }
//    else {
//        _versionLabel.text = [NSString stringWithFormat:@"%@ 更新至 %@", [SSPrivateUtil appBundleVersionIfInstalled:_model.pkgName], _model.versionName];
//    }
//    
//    _versionLabel.frame = [self frameForVersionLabel];
//}
//
//- (void)refreshInstallButton
//{
//    NSString * buttonBgName = nil;
//    NSString * buttonBgPressName = nil;
//    switch ([self checkAppStatus]) {
//        case TFAppStatusTypeNeedIntall:
//        {
//            [_installButton setTitle:@"安装" forState:UIControlStateNormal];
//            buttonBgName = @"btn.png";
//            buttonBgPressName = @"btn_press.png";
//        }
//            break;
//        case TFAppStatusTypeNeedUpdate:
//        {
//            [_installButton setTitle:@"更新" forState:UIControlStateNormal];
//            buttonBgName = @"btn2.png";
//            buttonBgPressName = @"btn2_press.png";
//        }
//            break;
//        case TFAppStatusTypeIsNewest:
//        {
//            [_installButton setTitle:@"已安装" forState:UIControlStateNormal];
//            buttonBgName = @"btn1.png";
//            buttonBgPressName = @"btn1_press.png";
//        }
//        default:
//            break;
//    }
//    
//    UIImage *normalBackgroundImage = [UIImage resourceImageNamed:buttonBgName];
//    normalBackgroundImage = [normalBackgroundImage stretchableImageWithLeftCapWidth:normalBackgroundImage.size.width/2
//                                                                       topCapHeight:normalBackgroundImage.size.height/2];
//    [_installButton setBackgroundImage:normalBackgroundImage forState:UIControlStateNormal];
//    
//    UIImage *highBackgroundImage = [UIImage resourceImageNamed:buttonBgPressName];
//    highBackgroundImage = [highBackgroundImage stretchableImageWithLeftCapWidth:highBackgroundImage.size.width/2
//                                                                   topCapHeight:highBackgroundImage.size.height/2];
//    [_installButton setBackgroundImage:highBackgroundImage forState:UIControlStateNormal];
//
//     _installButton.frame = [self frameForInstallButton];
//}
//
//- (TFAppStatusType)checkAppStatus
//{
//    BOOL appInstalled = [SSPrivateUtil isAppInstalled:_model.pkgName];
//    if (!appInstalled) {
//        return TFAppStatusTypeNeedIntall;
//    }
//    else {
//        NSString * installedVersion = [SSPrivateUtil appBundleVersionIfInstalled:_model.pkgName];
//        BOOL needUpdate = [TFAPPInfoCell checkNeedUpdate:_model.versionName currentInstallVersion:installedVersion];
//        if (needUpdate) {
//            return TFAppStatusTypeNeedUpdate;
//        }
//        else {
//            return TFAppStatusTypeIsNewest;
//        }
//    }
//}
//
//+ (BOOL)checkNeedUpdate:(NSString *)modelVersion currentInstallVersion:(NSString *)currentVersion
//{
//    BOOL hasNewVersion = NO;  // true means has new version
//    
//    if ([modelVersion length] == 0) return NO;
//    if ([currentVersion length] == 0) {
//        return YES;
//    }
//    
//    NSArray *currentVersionArray = [currentVersion componentsSeparatedByString:@"."];
//    NSArray *lastVersionArray = [modelVersion componentsSeparatedByString:@"."];
//    
//    int currentPosition = 0;
//    while (!hasNewVersion && (currentPosition < [currentVersionArray count] || currentPosition < [lastVersionArray count])) {
//        
//        int currentPositionValue = currentPosition < [currentVersionArray count] ?
//        [[currentVersionArray objectAtIndex:currentPosition] intValue] :
//        0;
//        int lastPositionValue = currentPosition < [lastVersionArray count] ?
//        [[lastVersionArray objectAtIndex:currentPosition] intValue] :
//        0;
//        
//        hasNewVersion = lastPositionValue > currentPositionValue;
//        
//        if (lastPositionValue < currentPositionValue) {
//            break;
//        }
//        
//        currentPosition ++;
//    }
//    
//    return hasNewVersion;
//}
//
//#pragma mark -- frame
//
//- (CGRect)frameForInstallButton
//{
//    CGRect rect = CGRectMake(self.frame.size.width - 44 - contentRightMargin, (self.frame.size.height - 30) / 2.f, 44, 30);
//    return rect;
//}
//
//- (CGRect)frameForVersionLabel
//{
//    [_versionLabel sizeToFit];
//    CGRect rect = _versionLabel.frame;
//    rect.origin.x = CGRectGetMinX([self frameForAppNameLabel]);
//    rect.origin.y = CGRectGetMaxY([self frameForAppNameLabel]) + 5;
//    return rect;
//}
//
//- (CGRect)frameForAppNameLabel
//{
//    [_appNameLabel sizeToFit];
//    CGRect rect = CGRectMake(CGRectGetMaxX([self frameForIconView]) + 10, CGRectGetMinY([self frameForIconView]) + 5, _appNameLabel.frame.size.width, _appNameLabel.frame.size.height);
//    return rect;
//}
//
//- (CGRect)frameForIconView
//{
//    CGRect rect = CGRectMake(CGRectGetMaxX([self frameForIndexLabel]) + 20, contentTopMargin, 50, 50);
//    return rect;
//}
//
//- (CGRect)frameForIndexLabel
//{
//    [_indexLabel sizeToFit];
//    return CGRectMake(contentLeftMargin, (self.frame.size.height - 30) / 2.f, _indexLabel.frame.size.width, _indexLabel.frame.size.height);
//}
//
//@end
