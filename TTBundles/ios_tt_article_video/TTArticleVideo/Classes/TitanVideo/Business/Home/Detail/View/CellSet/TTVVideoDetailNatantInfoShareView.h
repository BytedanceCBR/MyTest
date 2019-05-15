//
//  TTVVideoDetailNatantInfoShareView.h
//  Article
//
//  Created by lishuangyang on 2017/10/11.
//

#import <Foundation/Foundation.h>
#import "SSThemed.h"
#import "TTVVideoDetailNatantInfoViewModel.h"

typedef void(^TTVVideoDetailNatantInfoShareViewShareActionBlock)(NSString* shareAction);

@interface TTVVideoDetailNatantInfoShareView : SSThemedView

@property (nonatomic, copy) TTVVideoDetailNatantInfoShareViewShareActionBlock shareActionBlock;
@property (nonatomic, strong)TTVVideoDetailNatantInfoViewModel *viewModel;

- (instancetype)initWithWidth:(CGFloat)width  andinfoModel:(TTVVideoDetailNatantInfoViewModel *)infoModel;
- (void)updateDiggButton;
@end
