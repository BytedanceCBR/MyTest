//
//  TTVVideoDetailNatantInfoViewController.h
//  Article
//
//  Created by lishuangyang on 2017/5/21.
//
//

#import <UIKit/UIKit.h>
#import <TTUIWidget/SSViewControllerBase.h>
#import "TTVVideoDetailNatantInfoView.h"
#import "TTVDetailContext.h"

@class TTVVideoDetailNatantInfoViewModel;
@class TTVVideoDetailNatantInfoModel;

typedef void(^showExtendLinkBlock)(BOOL isAvailable);

@interface TTVVideoDetailNatantInfoViewController : SSViewControllerBase<TTVVideoDetailNatantInfoViewDelegate ,TTVDetailContext>

@property (nonatomic, strong)TTVVideoDetailNatantInfoView *infoView;
@property (nonatomic, copy) showExtendLinkBlock showBlock;    //调起extendView
@property (nonatomic, strong) TTVDetailStateStore *detailStateStore;
- (instancetype)initWithWidth: (CGFloat) width andinfoModel: (TTVVideoDetailNatantInfoModel *) infoModel;

@end
