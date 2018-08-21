//
//  TTSFQRShareView.m
//  QRDemo
//
//  Created by chenjiesheng on 2018/2/8.
//  Copyright © 2018年 陈杰生. All rights reserved.
//

#import "TTSFQRShareView.h"
#import "TTSFQRManager.h"

@interface TTSFQRShareView ()

@property (nonatomic, strong)UIImageView        *mahjongView;
@property (nonatomic, strong)UIImageView        *qrImageView;
@property (nonatomic, strong)UIImageView        *backgroundImageview;
@property (nonatomic, strong)UILabel            *tipLabel;
@property (nonatomic, strong)UILabel            *bottomTipLabel;
@property (nonatomic, assign)TTSFQRShareType     type;
@end

@implementation TTSFQRShareView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addSubview:self.backgroundImageview];
        [self.backgroundImageview addSubview:self.mahjongView];
        [self.backgroundImageview addSubview:self.qrImageView];
        [self.backgroundImageview addSubview:self.tipLabel];
    }
    return self;
}

- (instancetype)initWithMahjongImage:(UIImage *)mahjongImage
                           backImage:(UIImage *)backimage
                             tipText:(NSString *)tipText
                           qrContent:(NSString *)qrContent
                                type:(TTSFQRShareType)shareType
{
    self = [self init];
    if (self) {
        _type = shareType;
        if (mahjongImage) {
            self.mahjongView.hidden = NO;
            self.mahjongView.image = mahjongImage;
        }
        self.backgroundImageview.image = backimage;
        [self setupTipLabelWithText:tipText];
        if (!isEmptyString(qrContent)) {
            self.qrImageView.hidden = NO;
            UIImage *qrImage = [TTSFQRManager QRImageWithText:qrContent];
            self.qrImageView.image = qrImage;
        }
        [self refreshUI];
    }
    return self;
}

- (void)setupTipLabelWithText:(NSString *)text
{
    if (!text) {
        return;
    }
    NSArray<NSString *> *textList = [text componentsSeparatedByString:@"\n"];
    NSString *firstLineText = textList.firstObject;
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] init];
    NSMutableDictionary *secondLineDict = [NSMutableDictionary dictionary];
    [secondLineDict setValue:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    [secondLineDict setValue:[UIFont systemFontOfSize:30.f] forKey:NSFontAttributeName];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 20.f;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    [secondLineDict setValue:paragraphStyle forKey:NSParagraphStyleAttributeName];
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:text attributes:secondLineDict];
    [attributedStr appendAttributedString:str];
    if (textList.count > 1 && !isEmptyString(firstLineText)) {
        NSRange firstTextRange = [text rangeOfString:firstLineText];
        [attributedStr addAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:36.f]} range:firstTextRange];
    }
    self.tipLabel.attributedText = attributedStr;
    [self.tipLabel sizeToFit];
}

- (void)refreshUI
{
    if (self.backgroundImageview.image) {
        CGSize mahjongImageViewSize = CGSizeMake(231, 332);
        CGPoint mahjongImageViewCenter = CGPointMake(375, 694);
        CGSize qrImageViewSize = CGSizeMake(220, 220);
        CGPoint qrImageViewCenter = CGPointMake(375, 1040);
        CGPoint tipLabelCenter = CGPointMake(375, 441);
        switch (self.type) {
            case TTSFQRShareTypeAskCard:
                break;
            case TTSFQRShareTypeShareCard:
                break;
            case TTSFQRShareTypeOther:
                self.tipLabel.hidden = YES;
                break;
        }
        self.mahjongView.hidden = YES;
        self.backgroundImageview.hidden = NO;
        self.backgroundImageview.frame = CGRectMake(0, 0, 750, 1334);
        self.mahjongView.frame = CGRectMake(0, 0, mahjongImageViewSize.width, mahjongImageViewSize.height);
        self.mahjongView.center = mahjongImageViewCenter;
        self.qrImageView.frame = CGRectMake(0, 0, qrImageViewSize.width, qrImageViewSize.height);
        self.qrImageView.center = qrImageViewCenter;
        self.tipLabel.center = tipLabelCenter;
    } else {
        self.backgroundImageview.hidden = YES;
    }
}

+ (UIImage *)shareImageWithMahjongImage:(UIImage *)mahjongImage
                              backImage:(UIImage *)backimage
                                tipText:(NSString *)tipText
                              qrContent:(NSString *)qrContent
                                   type:(TTSFQRShareType)shareType
{
    TTSFQRShareView *view = [[TTSFQRShareView alloc] initWithMahjongImage:mahjongImage
                                                                     backImage:backimage
                                                                       tipText:tipText
                                                                     qrContent:qrContent
                                                                     type:shareType];
    UIImageView *shareView = view.backgroundImageview;
    UIGraphicsBeginImageContextWithOptions(shareView.frame.size, NO, 1);
    
    [shareView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    CGImageRef imageRef = newImage.CGImage;
    CGRect rect = CGRectMake(0, 0, shareView.bounds.size.width , shareView.bounds.size.height);
    CGImageRef imageRefRect = CGImageCreateWithImageInRect(imageRef, rect);
    newImage = [[UIImage alloc] initWithCGImage:imageRefRect];
//    NSData *imageData = UIImageJPEGRepresentation(newImage, 1);
//    newImage = [UIImage imageWithData:imageData];
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma Getter

- (UILabel *)tipLabel
{
    if (_tipLabel == nil) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.font = [UIFont systemFontOfSize:14.f];
        _tipLabel.textColor = [UIColor redColor];
        _tipLabel.numberOfLines = 0;
    }
    return _tipLabel;
}

- (UIImageView *)backgroundImageview
{
    if (_backgroundImageview == nil) {
        _backgroundImageview = [[UIImageView alloc] init];
        _backgroundImageview.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _backgroundImageview;
}

- (UIImageView *)mahjongView
{
    if (_mahjongView == nil) {
        _mahjongView = [[UIImageView alloc] init];
        _mahjongView.contentMode = UIViewContentModeScaleAspectFit;
        _mahjongView.hidden = YES;
    }
    return _mahjongView;
}

- (UIImageView *)qrImageView
{
    if (_qrImageView == nil) {
        _qrImageView = [[UIImageView alloc] init];
        _qrImageView.contentMode = UIViewContentModeScaleAspectFit;
        _qrImageView.hidden = YES;
    }
    return _qrImageView;
}

@end
