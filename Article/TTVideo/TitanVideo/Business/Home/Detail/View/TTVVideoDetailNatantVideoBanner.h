//
//  TTVVideoDetailNatantVideoBanner.h
//  Article
//
//  Created by pei yun on 2017/5/26.
//
//

#import <TTThemed/SSThemed.h>
#import "TTVVideoDetailNatantVideoBannerDataProtocol.h"

@interface TTVVideoDetailNatantVideoBanner : SSThemedView

@property (nonatomic, strong) id<TTVVideoDetailNatantVideoBannerDataProtocol> viewModel;
@property (nonatomic, copy) NSString *groupID;

@end
