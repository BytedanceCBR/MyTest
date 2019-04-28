//
//  TTInterfaceTipModel.h
//  Article
//
//  Created by chenjiesheng on 2017/6/23.
//
//

#import <Foundation/Foundation.h>
#import "TTGuideDispatchManager.h"
#import "TTInterfaceTipHeader.h"

@class TTInterfaceTipManager;
@interface TTInterfaceTipBaseModel : NSObject <TTGuideProtocol>

@property (nonatomic, weak) TTInterfaceTipManager *manager;
@property (nonatomic, strong) NSNumber  *topHeight;
@property (nonatomic, strong) NSNumber  *bottomHeight;
@property (nonatomic, strong) NSNumber  *tabbarHeight;
@property (nonatomic, weak) UIViewController<TTInterfaceBackViewControllerProtocol> *currenSelectedViewController;
@property (nonatomic, weak) UIView *mineIconView;
@property (nonatomic, copy) NSString * interfaceTipViewIdentifier;
@property (nonatomic, copy) BOOL(^checkShouldDiplayBlcok)(id);
- (void)setupContextWithDict:(NSDictionary *)dict;
@end
