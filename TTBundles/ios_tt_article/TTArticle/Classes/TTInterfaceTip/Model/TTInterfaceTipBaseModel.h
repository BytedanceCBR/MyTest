//
//  TTInterfaceTipModel.h
//  Article
//
//  Created by chenjiesheng on 2017/6/23.
//
//

#import <Foundation/Foundation.h>
#import "TTInterfaceTipHeader.h"
#import <TTDialogDirector.h>

@class TTInterfaceTipManager;
@interface TTInterfaceTipBaseModel : NSObject

@property (nonatomic, weak) TTInterfaceTipManager *manager;
@property (nonatomic, strong) NSNumber  *topHeight;
@property (nonatomic, strong) NSNumber  *bottomHeight;
@property (nonatomic, strong) NSNumber  *tabbarHeight;
@property (nonatomic, assign) TTDialogPriority dialogPriority;
@property (nonatomic, weak) UIViewController<TTInterfaceBackViewControllerProtocol> *currenSelectedViewController;
@property (nonatomic, weak) UIView *mineIconView;
@property (nonatomic, copy) NSString * interfaceTipViewIdentifier;
@property (nonatomic, copy) BOOL(^checkShouldDiplayBlcok)(id);
@property (nonatomic, weak) UIView          *customBackView;
@property (nonatomic, assign)BOOL            useCustomBackView;
- (void)setupContextWithDict:(NSDictionary *)dict;
- (BOOL)checkShouldDisplay;

/**
 如果本次没有展示出来，是否需要在下次首页出来的时候展示

 @return 默认返回NO
 */
- (BOOL)needShowAfterMainListDidAppear;
@end
