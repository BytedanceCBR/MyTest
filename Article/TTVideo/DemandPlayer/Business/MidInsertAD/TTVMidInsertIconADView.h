//
//  TTVMidInsertIconADView.h
//  Article
//
//  Created by lijun.thinker on 07/09/2017.
//
//

#import <UIKit/UIKit.h>

@interface TTVMidInsertIconADView : UIView

@property (nonatomic, copy) void (^TTVMidInsertIconADGoDetailAction)(void);
@property (nonatomic, copy) void (^TTVMidInsertIconADCloseAction)(void);

- (instancetype)initWithFrame:(CGRect)frame imageModel:(TTImageInfosModel *)imageModel closeEnabled:(BOOL)enable;
- (void)updatSizeForFullScreenStatusChanged:(BOOL)isFullScreen;

@end
