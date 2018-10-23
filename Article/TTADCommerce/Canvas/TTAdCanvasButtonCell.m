//
//  TTAdCanvasButtonView.m
//  Article
//
//  Created by yin on 2017/3/28.
//
//

#import "TTAdCanvasButtonCell.h"
#import "TTAdManager.h"
#import "SSWebViewController.h"
#import "TTAdCanvasUtils.h"
#import "TTUIResponderHelper.h"
#import <TTServiceKit/TTServiceCenter.h>
#import "TTAdManagerProtocol.h"
#import "TTRouteService.h"


@interface TTAdCanvasButtonCell()

@property (nonatomic, strong) UIButton* button;
@property (nonatomic, strong) TTAdCanvasLayoutModel* model;

@end

@implementation TTAdCanvasButtonCell

- (instancetype)initWithWidth:(CGFloat)width
{
    self = [super initWithWidth:width];
    if (self) {
        [self setSubViews];
    }
    return self;
}

- (void)setSubViews
{
    self.button = [[UIButton alloc] init];
    [self addSubview:self.button];
    [self.button addTarget:self action:@selector(buttonTouched:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)refreshWithModel:(TTAdCanvasLayoutModel *)model
{
    self.model = model;
    [self.button setTitle:model.data.text forState:UIControlStateNormal];
    self.button.titleLabel.font = [UIFont systemFontOfSize:model.styles.fontSize.floatValue];
    self.button.layer.cornerRadius = model.styles.borderRadius.floatValue;
    self.button.layer.masksToBounds = YES;
    self.button.layer.borderWidth = model.styles.borderWidth.floatValue;
    self.button.backgroundColor = [TTAdCanvasUtils colorWithCanvasRGBAString:model.styles.backgroundColor];
    self.button.layer.borderColor = [TTAdCanvasUtils colorWithCanvasRGBAString:model.styles.borderColor].CGColor;
    
    self.button.titleLabel.textColor = [TTAdCanvasUtils colorWithCanvasRGBAString:model.styles.color];
    
}


- (void)canvasCell:(TTAdCanvasBaseCell *)cell showStatus:(TTAdCanvasItemShowStatus)showStatus itemIndex:(NSInteger)itemIndex
{
    switch (showStatus) {
        case TTAdCanvasItemShowStatus_WillDisplay:
            [self trackShow];
            break;
            
        default:
            break;
    }
}

- (void)trackShow
{
    if (self.model.itemType == TTAdCanvasItemType_Button) {
        [[TTAdCanvasManager sharedManager] trackCanvasTag:@"detail_immersion_ad" label:@"impression_button" dict:nil];
    }
    else if (self.model.itemType == TTAdCanvasItemType_DownloadButton)
    {
        [[TTAdCanvasManager sharedManager] trackCanvasTag:@"detail_immersion_ad" label:@"impression_download" dict:nil];
    }
    else if (self.model.itemType == TTAdCanvasItemType_PhoneButton)
    {
        [[TTAdCanvasManager sharedManager] trackCanvasTag:@"detail_immersion_ad" label:@"impression_call" dict:nil];
    }
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat width = (self.model.styles.width.floatValue/100)* self.constrainWidth;
    width = width <= self.constrainWidth? width: self.constrainWidth;
    self.button.size = CGSizeMake(width, self.model.styles.height.floatValue);
    self.button.centerX = self.width/2;
    self.button.top = self.model.styles.marginTop.floatValue;
}

- (void)buttonTouched:(UIButton*)button
{
    if (!self.model) {
        return;
    }
    switch (self.model.itemType) {
        case TTAdCanvasItemType_Button:
        {
            NSString* url = self.model.data.url;
            if (isEmptyString(url)) {
                return;
            }
            if ([[TTRoute sharedRoute] canOpenURL:[TTStringHelper URLWithURLString:url]]) {
                [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:url]];
            } else {
                SSWebViewController * controller = [[SSWebViewController alloc] initWithSupportIPhoneRotate:YES];
                [controller requestWithURL:[TTStringHelper URLWithURLString:url]];
                UINavigationController *topController = [TTUIResponderHelper topNavigationControllerFor: nil];
                [topController pushViewController:controller animated:YES];
            }
            
            [[TTAdCanvasManager sharedManager] trackCanvasTag:@"detail_immersion_ad" label:@"click_button" dict:nil];
        }
            break;
        case TTAdCanvasItemType_PhoneButton:
        {
            if (self.model.data.telnum.longLongValue > 0) {
                [TTAdManager call_callWithNumber:self.model.data.telnum];
                [TTAdManageInstance canvas_canvasCall];
            }
        }
            break;
        case TTAdCanvasItemType_DownloadButton:
        {
            NSMutableDictionary* dict = [NSMutableDictionary dictionary];
            [dict setValue:self.model.data.iosLink forKey:@"download_url"];
            [dict setValue:self.model.data.apple_id forKey:@"apple_id"];
            [dict setValue:self.model.data.open_url forKey:@"open_url"];
            [dict setValue:self.model.data.ipa_url forKey:@"ipa_url"];
            id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];
            [[adManagerInstance class] app_downloadAppDict:dict];
            [[TTAdCanvasManager sharedManager] trackCanvasTag:@"detail_immersion_ad" label:@"click" dict:nil];
        }
            break;
        default:
            break;
    }
}

+ (CGFloat)heightForModel:(TTAdCanvasLayoutModel *)model inWidth:(CGFloat)width
{
    return model.styles.marginTop.floatValue + model.styles.marginBottom.floatValue + model.styles.height.floatValue;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
