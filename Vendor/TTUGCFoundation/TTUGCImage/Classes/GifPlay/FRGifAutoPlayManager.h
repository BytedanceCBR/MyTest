//
//  FRGifAutoPlayManager.h
//  Pods
//
//  Created by lipeilun on 2018/6/22.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <IGListKit/IGListDiff.h>
#import <IGListKit/IGListAssert.h>

extern NSString *const kGifAutoPlayOverNotification;

extern NSString *const kGifBeginBrowserNotification;

extern NSString *const kGifPlayAbortOverNotification;

@protocol FRGifAutoPlayMethods <IGListDiffable>
- (BOOL)ugc_startGifPlay;
- (void)ugc_stopGifPlay;
- (void)ugc_startGifPlayWithNoScroll;
- (void)ugc_stopGifPlayWithNoScroll;
- (BOOL)ugc_gifEnoughToPlay;
- (BOOL)ugc_singleGif;
- (void)ugc_gifControllerRange:(NSRange)range;
@end

@protocol FRGifAutoPlayCellProtocol <NSObject>
- (UIView<FRGifAutoPlayMethods> *)ugc_gifPlayController;
@end

@interface FRGifAutoPlayManager : NSObject

+ (FRGifAutoPlayManager *)sharedInstance;

- (void)startGifPlayInTableView:(UITableView *)tableView;

- (void)insertGifPlayHeader:(id<FRGifAutoPlayCellProtocol>)object;

- (void)removeGifPlayHeader:(id<FRGifAutoPlayCellProtocol>)object;

@end
