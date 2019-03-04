//
//  FHAgencyNameInfoView.m
//  FHHouseDetail
//
//  Created by 春晖 on 2019/3/4.
//

#import "FHAgencyNameInfoView.h"
#import <Masonry/Masonry.h>
#import <FHCommonUI/UIColor+Theme.h>
#import <FHCommonUI/UIFont+House.h>
#import "FHDetailBaseModel.h"
#import <BDWebImage/BDWebImage.h>

@interface FHAgencyNameInfoView ()

@property(nonatomic , strong) UILabel *infoLabel;
@property(nonatomic , strong) NSArray<FHDetailDataCertificateLabelsModel *> * infos;
@property(nonatomic , strong) NSMutableDictionary *iconImgDict;

@end

@implementation FHAgencyNameInfoView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 2;
        self.layer.masksToBounds = YES;
    }
    return self;
}

-(UILabel *)infoLabel
{
    if (!_infoLabel) {
        _infoLabel = [[UILabel alloc] init];
        [self addSubview:_infoLabel];
        _infoLabel.textAlignment = NSTextAlignmentCenter;
        [_infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.mas_equalTo(self);
            make.left.mas_greaterThanOrEqualTo(5);
            make.right.mas_lessThanOrEqualTo(self).offset(-5);
            make.centerX.mas_equalTo(self);
        }];
    }
    return _infoLabel;
}

-(NSMutableDictionary *)iconImgDict
{
    if (!_iconImgDict) {
        _iconImgDict = [NSMutableDictionary new];
    }
    return _iconImgDict;
}

-(void)setAgencyNameInfo:(NSArray<FHDetailDataCertificateLabelsModel *> *) info
{
    if (info == self.infos) {
        return;
    }
    self.infos = info;
    
    NSMutableSet *iconUrls = [[NSMutableSet alloc] init];
    for (FHDetailDataCertificateLabelsModel *model in info) {
        if (model.icon.length > 0) {
            [iconUrls addObject:model.icon];
        }
    }
    
    __weak typeof(self) wself = self;
    for (NSString *url in iconUrls) {
        [[BDWebImageManager sharedManager] requestImage:[NSURL URLWithString:url] options:BDImageRequestHighPriority complete:^(BDWebImageRequest *request, UIImage *image, NSData *data, NSError *error, BDWebImageResultFrom from) {
            if (!error && image) {
                wself.iconImgDict[url] = image;
                [wself updateInfos];
            }
        }];
    }
    
    [self updateInfos];
}

-(void)updateInfos
{    
    NSDictionary *dict = @{  NSFontAttributeName:[UIFont themeFontRegular:10],
                             NSForegroundColorAttributeName:[UIColor themeRed3]
                             };
    NSMutableAttributedString *infoStr = [[NSMutableAttributedString alloc] init];
    NSAttributedString *blankStr = [[NSAttributedString alloc] initWithString:@"    "  attributes:dict];
    
    for (FHDetailDataCertificateLabelsModel *model in self.infos) {
        NSTextAttachment *attachment = nil;
        if (model.icon.length > 0 && self.iconImgDict[model.icon]) {
            attachment = [[NSTextAttachment alloc] init];
            attachment.image = self.iconImgDict[model.icon];
            attachment.bounds = CGRectMake(-2, -1.5, 10, 10);
        }
        if (attachment) {
            NSAttributedString *checkAtttr = [NSAttributedString attributedStringWithAttachment:attachment];
            [infoStr appendAttributedString:checkAtttr];
        }
        dict = @{  NSFontAttributeName:[UIFont themeFontRegular:10],
                   NSForegroundColorAttributeName:[UIColor colorWithHexString:model.fontColor]?:[UIColor themeRed3]
                   };
        NSAttributedString *nameStr = [[NSAttributedString alloc] initWithString:model.tag  attributes:dict];
        [infoStr appendAttributedString:nameStr];
        
        [infoStr appendAttributedString:blankStr];
        
    }
    
    self.infoLabel.attributedText = infoStr;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
