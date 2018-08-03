//
//  FRPostThreadAddLocationView.m
//  Article
//
//  Created by ZhangLeonardo on 15/7/15.
//
//

#import "FRPostThreadAddLocationView.h"
#import "FRForumLocationSelectViewController.h"
#import "TTNavigationController.h"
#import "TTIconFontDefine.h"
#import "TTUGCPodBridge.h"
#import "TTPlacemarkItemProtocol.h"
#import "UIImage+TTThemeExtension.h"
#import "TTTrackerWrapper.h"
#import "TTDeviceHelper.h"
#import "UIViewAdditions.h"
#import "TTUIResponderHelper.h"
#import "TTUGCPodBridge.h"


@interface FRPostThreadAddLocationView ()

@property (nonatomic, strong) NSArray<id<TTPlacemarkItemProtocol>> *placemarks;

@end

@implementation FRPostThreadAddLocationView

- (instancetype)initWithFrame:(CGRect)frame andShowEtStatus:(FRShowEtStatus)showEtStatus {
    self = [super initWithFrame:frame];
    if (self) {
        [self componentInitWithShowEtStatus:showEtStatus];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame andShowEtStatus:FRShowEtStatusOfTitle];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self componentInitWithShowEtStatus:FRShowEtStatusOfTitle];
    return self;
}

- (void)componentInitWithShowEtStatus:(FRShowEtStatus)showEtStatus {
    self.backgroundColorThemeKey = kColorBackground4;
    self.button = [SSThemedButton buttonWithType:UIButtonTypeCustom];
    [_button setImage:[UIImage themedImageNamed:@"icon_place_inactive"] forState:UIControlStateNormal];
    [_button setImage:[UIImage themedImageNamed:@"icon_place_inactive"] forState:UIControlStateHighlighted];
    _button.titleLabel.font = [UIFont systemFontOfSize:12];
    _button.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _button.titleColorThemeKey = kColorText3;
    _button.borderColorThemeKey = kColorLine1;
    _button.layer.borderWidth = [TTDeviceHelper ssOnePixel];
    _button.layer.cornerRadius = 13.0f;
    _button.clipsToBounds = YES;
    [_button setTitle:@"所在位置？" forState:UIControlStateNormal];
    _button.imageEdgeInsets = UIEdgeInsetsMake(1.f, 0, 0, [TTDeviceHelper isScreenWidthLarge320] ? 5.f : 3.f);
    _button.titleEdgeInsets = UIEdgeInsetsMake(0, 2.f, 0, 0);
    [_button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];

    _button.top = 5.f;
    _button.left = 10.f;
    [_button sizeToFit];
    _button.height = 26.f;
    _button.width += 14.f;

    [self addSubview:_button];

    [self reloadThemeUI];

    if (showEtStatus & FRShowEtStatusOfLocation) {
        //服务器控制是否默认选中地理位置
        self.selectedLocation = [self getLastLocationEntity];
    }

    [self refresh];

    // 定位并且反编码
    __weak typeof(self) weakSelf = self;
    [[TTUGCPodBridge sharedInstance] regeocodeWithCompletionHandler:^(NSArray *placemarks) {
        weakSelf.placemarks = placemarks;
    }];
}

- (void)themeChanged:(NSNotification *)notification {
    [super themeChanged:notification];

    [self refresh];
}

- (void)buttonClicked:(UIButton *)sender {
    [TTTrackerWrapper eventV3:@"click_location" params:nil];
    //更新最新的定位信息
    NSArray<id<TTPlacemarkItemProtocol>> *placemarks = [[TTUGCPodBridge sharedInstance] placemarks];
    if (_placemarks.count == 0) {
        self.placemarks = placemarks;
    } else if ([(id<TTPlacemarkItemProtocol>) placemarks.firstObject timestamp] > [(id<TTPlacemarkItemProtocol>) _placemarks.firstObject timestamp]) {
        self.placemarks = placemarks;
    }

    if (self.delegate && [self.delegate respondsToSelector:@selector(addLocationViewWillPresent)]) {
        [self.delegate addLocationViewWillPresent];
    }

    FRForumLocationSelectViewController *viewController =
        [[FRForumLocationSelectViewController alloc] initWithSelectedLocation:_selectedLocation
                                                                   placemarks:_placemarks
                                                             completionHandle:^(FRLocationEntity *location, BOOL dismiss) {
                                                                 if (!dismiss) {
                                                                     self.selectedLocation = location;
                                                                     [self refresh];
                                                                 }

                                                                 if (self.delegate && [self.delegate respondsToSelector:@selector(addLocationViewDidDismiss)]) {
                                                                     [self.delegate addLocationViewDidDismiss];
                                                                 }
                                                             }];
    viewController.concernId = self.concernId;
    viewController.trackDic = self.trackDic;
    TTNavigationController *navigationController = [[TTNavigationController alloc] initWithRootViewController:viewController];
    navigationController.ttDefaultNavBarStyle = @"White";
    [[TTUIResponderHelper topViewControllerFor:self] presentViewController:navigationController animated:YES completion:nil];
}

- (void)refresh {
    if (_selectedLocation) {
        [_button setImage:[UIImage themedImageNamed:@"icon_place_active"] forState:UIControlStateNormal];
        [_button setImage:[UIImage themedImageNamed:@"icon_place_active"] forState:UIControlStateHighlighted];
        NSMutableString *location = [NSMutableString string];
        if (_selectedLocation.locationType == FRLocationEntityTypeCity && !isEmptyString(_selectedLocation.city)) {
            [location appendString:_selectedLocation.city];
        }
        if (!isEmptyString(_selectedLocation.locationName)) {
            if (location.length > 0) {
                [location appendFormat:@" %@", _selectedLocation.locationName];
            } else {
                [location appendString:_selectedLocation.locationName];
            }
        }

        NSUInteger maxLength = 13;
        NSString *text = [location copy];
        if (text.length > maxLength) {
            text = [[text substringToIndex:maxLength] stringByAppendingString:@"..."];
        }

        text = [text stringByAppendingString:@" "];

        NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:text attributes:@{
            NSFontAttributeName: [UIFont systemFontOfSize:12],
            NSForegroundColorAttributeName: SSGetThemedColorWithKey(kColorText1),
        }];

        [mutableAttributedString appendAttributedString:[[NSAttributedString alloc] initWithString:iconfont_right_arrow
                                                                                        attributes:@{
                                                                                            NSFontAttributeName: [UIFont fontWithName:@"iconfont" size:11.f],
                                                                                            NSForegroundColorAttributeName: SSGetThemedColorWithKey(kColorText1),
                                                                                            NSBaselineOffsetAttributeName: @(0.f)
                                                                                        }]];

        [_button setAttributedTitle:mutableAttributedString forState:UIControlStateNormal];
        [_button setTitleColor:SSGetThemedColorWithKey(kColorText1) forState:UIControlStateNormal];
        [_button sizeToFit];
        _button.height = 26.f;
        _button.width += 20.f;
    } else {
        [_button setImage:[UIImage themedImageNamed:@"icon_place_inactive"] forState:UIControlStateNormal];
        [_button setImage:[UIImage themedImageNamed:@"icon_place_inactive"] forState:UIControlStateHighlighted];
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:@"所在位置？" attributes:@{
            NSFontAttributeName: [UIFont systemFontOfSize:12],
            NSForegroundColorAttributeName: SSGetThemedColorWithKey(kColorText3),
        }];
        [_button setAttributedTitle:attributedString forState:UIControlStateNormal];
        [_button sizeToFit];
        _button.height = 26.f;
        _button.width += 14.f;
    }
}

#pragma mark - Utils

//获取最近一次定位信息
- (FRLocationEntity *)getLastLocationEntity {
    //定位成功，获取附近POI

    id <TTPlacemarkItemProtocol> placemarkItem = [[TTUGCPodBridge sharedInstance] getPlacemarkItem];

    if (placemarkItem) {
        FRLocationEntity *location = [[FRLocationEntity alloc] init];
        location.locationType = FRLocationEntityTypeCity;
        location.latitude = placemarkItem.coordinate.latitude;
        location.longitude = placemarkItem.coordinate.longitude;
        location.locationName = placemarkItem.district;
        if (!isEmptyString(placemarkItem.city)) {
            location.city = placemarkItem.city;
        } else if (!isEmptyString(placemarkItem.province)) {
            location.city = placemarkItem.province;
        }

        return location;
    }
    return nil;
}

@end
