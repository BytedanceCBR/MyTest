//
//  TTVMidInsertADGuideCountdownView.h
//  Article
//
//  Created by pei yun on 2017/10/29.
//

#import "SSViewBase.h"
#import "TTVMidInsertADModel.h"
#import "TTVADGuideCountdownViewProtocol.h"

@interface TTVMidInsertADGuideCountdownView : SSViewBase <TTVADGuideCountdownViewProtocol>

@property (nonatomic, copy) void (^guideCountdownCompleted)();

- (instancetype)initWithFrame:(CGRect)frame pasterADModel:(TTVMidInsertADModel *)adModel;
- (void)terminateTimer;

@end
