//
//  TTRedPacketViewController.h
//  Article
//
//  Created by lipeilun on 2017/7/12.
//
//

#import "SSViewControllerBase.h"
#import "TTRedPacketViewWrapper.h"
@class TTRedPacketViewWrapper;
@interface TTRedPacketViewController : SSViewControllerBase <TTRedPacketViewWrapperDelegate>
@property (nonatomic, strong) UIImage *backingImage;
- (instancetype)initWithStyle:(TTRedPacketViewStyle)style
                    redpacket:(FRRedpackStructModel *)redpacket
                        track:(TTRedPacketTrackModel *)trackModel
               viewController:(UIViewController *)fromViewController;
@end
