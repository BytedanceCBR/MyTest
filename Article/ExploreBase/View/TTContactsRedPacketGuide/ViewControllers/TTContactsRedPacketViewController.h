//
//  TTContactsRedPacketViewController.h
//  Article
//  通讯录红包打开及列表页
//
//  Created by Jiyee Sheng on 8/1/17.
//
//


#import "SSViewControllerBase.h"
#import "TTContactsRedPacketManager.h"

@interface TTContactsRedPacketViewController : SSViewControllerBase

- (instancetype)initWithContactUsers:(NSArray *)contactUsers
                  fromViewController:(UIViewController *)fromViewController
                                type:(TTContactsRedPacketViewControllerType)type
                           viewModel:(TTRedPacketDetailBaseViewModel *)viewModel
                         extraParams:(NSDictionary *)extraParams;

@property (nonatomic, strong) UIImage *backgroundImage;
@property (nonatomic, assign) BOOL fromPush; //push出来的

@end
