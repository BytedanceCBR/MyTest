//
//  FRPostThreadAddLocationView.m
//  Article
//
//  Created by ZhangLeonardo on 15/7/15.
//
//

#import "FRPostThreadAddLocationView.h"
#import "FRForumLocationSelectViewController.h"
#import <TTUIWidget/TTNavigationController.h>
#import <TTPlatformBaseLib/TTIconFontDefine.h>
#import <TTPlatformBaseLib/TTTrackerWrapper.h>
#import <TTPlatformUIModel/TTCategoryDefine.h>
#import <TTLocationManager/TTLocationManager.h>
#import <TTThemed/UIImage+TTThemeExtension.h>
#import <TTBaseLib/TTDeviceHelper.h>
#import <TTBaseLib/UIViewAdditions.h>
#import <TTBaseLib/TTUIResponderHelper.h>
#import "TTDeviceHelper.h"


@interface FRPostThreadAddLocationView ()

@property (nonatomic, strong) NSArray<TTPlacemarkItem *> *placemarks;
@property (nonatomic, strong) TTUGCPostThreadLocationButton *locationButton;

@property (nonatomic, assign) FRShowEtStatus showEtStatus;

@end

@implementation FRPostThreadAddLocationView

- (instancetype)initWithFrame:(CGRect)frame andShowEtStatus:(FRShowEtStatus)showEtStatus {
    self = [super initWithFrame:frame];
    if (self) {
        self.showEtStatus = showEtStatus;
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
    
    self.locationButton = [[TTUGCPostThreadLocationButton alloc] initWithFrame:CGRectMake(10, 5, 10, 26.0)];//宽度无意义
    [self addSubview:self.locationButton];
    self.locationButton.layer.borderWidth = [TTDeviceHelper ssOnePixel];
    self.locationButton.borderColorThemeKey = kColorLine1;
    self.locationButton.layer.cornerRadius = 13.0;
    self.locationButton.clipsToBounds = YES;
    [self.locationButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];

    switch ([TTDeviceHelper getDeviceType]) {
        case TTDeviceMode480:
        case TTDeviceMode568:
            self.locationButton.maxTextWidth = 100.0;
            break;
        case TTDeviceMode667:
        case TTDeviceModePad:
            self.locationButton.maxTextWidth = 155.0;
            break;
        case TTDeviceMode736:
        case TTDeviceMode812:
        case TTDeviceMode896:
            self.locationButton.maxTextWidth = 194.0;
            break;
        default:
            break;
    }

    [self reloadThemeUI];

    if (showEtStatus & FRShowEtStatusOfLocation || [self.categotyID isEqualToString:@""]) {
        //服务器控制是否默认选中地理位置
        self.selectedLocation = [self getLastLocationEntity];
    }
    
    [self refresh];
    
    // 定位并且反编码
    __weak typeof(self) weakSelf = self;
    [[TTLocationManager sharedManager] startGeolocatingWithCompletionHandler:^(NSArray *placemarks) {
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
    NSArray<TTPlacemarkItem *> *placemarks = [TTLocationManager sharedManager].placemarks;
    if (_placemarks.count == 0) {
        self.placemarks = placemarks;
    } else if ([(TTPlacemarkItem *) placemarks.firstObject timestamp] > [(TTPlacemarkItem *) _placemarks.firstObject timestamp]) {
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
    viewController.categoryID = self.categotyID;
    viewController.trackDic = self.trackDic;
    TTNavigationController *navigationController = [[TTNavigationController alloc] initWithRootViewController:viewController];
    navigationController.ttDefaultNavBarStyle = @"White";
    [[TTUIResponderHelper topViewControllerFor:self] presentViewController:navigationController animated:YES completion:nil];
}

- (void)refresh {
    if (_selectedLocation) {
        NSMutableString *location = [NSMutableString string];
        if (_selectedLocation.locationType == FRLocationEntityTypeCity && !isEmptyString(_selectedLocation.city)) {
            [location appendString:_selectedLocation.city];
        }
        if (!isEmptyString(_selectedLocation.locationName) && ![_selectedLocation.city isEqualToString:_selectedLocation.locationName]) {
            if (location.length > 0) {
                [location appendFormat:@" %@", _selectedLocation.locationName];
            } else {
                [location appendString:_selectedLocation.locationName];
            }
        }
        [self.locationButton configWithActiveStatus:YES text:location];
    } else {
        [self.locationButton configWithActiveStatus:NO text:@"所在位置？"];
    }
}

#pragma mark - Utils

//获取最近一次定位信息
- (FRLocationEntity *)getLastLocationEntity {
    //定位成功，获取附近POI

    TTPlacemarkItem *placemarkItem = [TTLocationManager sharedManager].placemarkItemInCoordinateGCJ02;

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

- (void)showCurrentGeoLocation {
    
    if (!self.selectedLocation) {
        //服务器控制是否默认选中地理位置 add by zyk 需要后续看是否服务器控制
        self.selectedLocation = [self getLastLocationEntity];
    }
}

#pragma mark - setter

- (void)setCategotyID:(NSString *)categotyID {
    _categotyID = categotyID;
    
    [self showCurrentGeoLocation];
}

@end

@interface TTUGCPostThreadLocationButton ()

@property (nonatomic, strong) SSThemedImageView *placeImageView;
@property (nonatomic, strong) SSThemedTextView *textView;
@property (nonatomic, strong) SSThemedImageView *rightArrowImageView;

@end

@implementation TTUGCPostThreadLocationButton

- (void)configWithActiveStatus:(BOOL)activeStatus text:(NSString *)text {
    if (activeStatus) {
        self.placeImageView.imageName = @"icon_place_active";
    } else {
        self.placeImageView.imageName = @"icon_place_inactive";
    }
    
    NSMutableParagraphStyle *paraStyle = [NSMutableParagraphStyle new];
    paraStyle.maximumLineHeight = 16.0f;
    paraStyle.minimumLineHeight = 16.0f;

    NSDictionary *dict = @{
                           NSFontAttributeName:[UIFont systemFontOfSize:12.0],
                           NSForegroundColorAttributeName:activeStatus? SSGetThemedColorWithKey(kColorText1):SSGetThemedColorWithKey(kColorText3),
                           NSKernAttributeName:@(-0.1),
                           NSParagraphStyleAttributeName:paraStyle
                           };
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:text attributes:dict];
    
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:attrString];
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [textStorage addLayoutManager:layoutManager];

    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:CGSizeMake(self.maxTextWidth, CGFLOAT_MAX)];
    [layoutManager addTextContainer:textContainer];
    NSRange range = NSMakeRange(attrString.length - 1, 1);
    NSRange glyphRange;
    [layoutManager characterRangeForGlyphRange:range actualGlyphRange:&glyphRange];

    CGRect boundingRect = [layoutManager boundingRectForGlyphRange:glyphRange inTextContainer:textContainer];
    if (boundingRect.origin.y > 10) {
        //1行放不下
        self.textView.frame = CGRectMake(self.placeImageView.right - 1, 4, self.maxTextWidth+8, 16.0);
        self.textView.textContainer.lineBreakMode = NSLineBreakByTruncatingTail;

    } else {
        CGFloat textMaxX = boundingRect.origin.x + boundingRect.size.width;
        
        self.textView.frame = CGRectMake(self.placeImageView.right - 1, 4, textMaxX + 8, 16.0);
        self.textView.textContainer.lineBreakMode = NSLineBreakByWordWrapping;


    }
    self.textView.textContainer.size = self.textView.bounds.size;
    self.textView.textContainer.widthTracksTextView = NO;
    self.textView.textContainer.heightTracksTextView = NO;
    self.textView.textContainerInset = UIEdgeInsetsZero;
    self.textView.attributedText = attrString;
    
    self.textView.userInteractionEnabled = NO;


    if (activeStatus) {
        self.rightArrowImageView.hidden = NO;
        
        NSRange range = NSMakeRange(attrString.length - 1, 1);
        NSRange glyphRange;
        [self.textView.layoutManager characterRangeForGlyphRange:range actualGlyphRange:&glyphRange];
        
        CGRect boundingRect = [self.textView.layoutManager boundingRectForGlyphRange:glyphRange inTextContainer:self.textView.textContainer];
        CGFloat realTextMax = boundingRect.origin.x + boundingRect.size.width;

        
        
        self.rightArrowImageView.frame = CGRectMake(self.textView.left + realTextMax + 6, 8.0, 6, 10);
        self.width = self.rightArrowImageView.right + 10.0;
    } else {
        _rightArrowImageView.hidden = YES;
        self.width = self.textView.right - 3.0;
    }
}

- (SSThemedImageView *)placeImageView {
    if (!_placeImageView) {
        _placeImageView = [[SSThemedImageView alloc] initWithFrame:CGRectMake(7, 5, 16, 16)];
        _placeImageView.imageName = @"icon_place_inactive";
        [self addSubview:_placeImageView];
        
    }
    return _placeImageView;
}

- (SSThemedImageView *)rightArrowImageView {
    if (!_rightArrowImageView) {
        _rightArrowImageView = [[SSThemedImageView alloc] init];
        _rightArrowImageView.imageName = @"location_arrow_right";
        [self addSubview:_rightArrowImageView];
    }
    return _rightArrowImageView;
}

- (SSThemedTextView *)textView {
    if (!_textView) {
        _textView = [[SSThemedTextView alloc] init];
        _textView.backgroundColor = [UIColor clearColor];
        _textView.textContainer.widthTracksTextView = NO;
        _textView.textContainer.heightTracksTextView = NO;
        _textView.textContainer.lineBreakMode = NSLineBreakByTruncatingTail;
        _textView.textContainerInset = UIEdgeInsetsZero;

        [self addSubview:_textView];
    }
    return _textView;
}
@end
