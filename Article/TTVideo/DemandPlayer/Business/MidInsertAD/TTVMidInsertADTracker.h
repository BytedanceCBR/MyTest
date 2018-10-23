//
//  TTVMidInsertADTracker.h
//  Article
//
//  Created by lijun.thinker on 08/09/2017.
//
//

#import <Foundation/Foundation.h>

@class TTVMidInsertADModel;
@interface TTVMidInsertADTracker : NSObject

// duration是毫秒
+ (void)sendADEventWithlabel:(NSString *)label
                     adModel:(TTVMidInsertADModel *)adModel
                    duration:(NSTimeInterval)duration
                       extra:(NSDictionary *)extra;

+ (void)sendIconADShowEventForADModel:(TTVMidInsertADModel *)adModel duration:(NSTimeInterval)duration isInDetail:(BOOL)isInDetail;
+ (void)sendIconADShowOverEventForADModel:(TTVMidInsertADModel *)adModel duration:(NSTimeInterval)duration isInDetail:(BOOL)isInDetail;
+ (void)sendIconADClickEventForADModel:(TTVMidInsertADModel *)adModel duration:(NSTimeInterval)duration isInDetail:(BOOL)isInDetail extra:(NSDictionary *)extra;

+ (void)sendMidInsertADPlayOverEventForADModel:(TTVMidInsertADModel *)adModel duration:(NSTimeInterval)duration isInDetail:(BOOL)isInDetail;
+ (void)sendMidInsertADPlayBreakEventForADModel:(TTVMidInsertADModel *)adModel duration:(NSTimeInterval)duration effective:(BOOL)effective isInDetail:(BOOL)isInDetail;
+ (void)sendMidInsertADClickCloseEventForADModel:(TTVMidInsertADModel *)adModel duration:(NSTimeInterval)duration effective:(BOOL)effective isInDetail:(BOOL)isInDetail;
+ (void)sendMidInsertADClickDetailEventForADModel:(TTVMidInsertADModel *)adModel duration:(NSTimeInterval)duration isInDetail:(BOOL)isInDetail extra:(NSDictionary *)extra;
+ (void)sendMidInsertADClickVideoEventForADModel:(TTVMidInsertADModel *)adModel duration:(NSTimeInterval)duration isInDetail:(BOOL)isInDetail;
+ (void)sendMidInsertADPlayEventForADModel:(TTVMidInsertADModel *)adModel duration:(NSTimeInterval)duration isInDetail:(BOOL)isInDetail;
+ (void)sendMidInsertADShowEventForADModel:(TTVMidInsertADModel *)adModel duration:(NSTimeInterval)duration isInDetail:(BOOL)isInDetail;
+ (void)sendMidInsertADFullScreenEventForADModel:(TTVMidInsertADModel *)adModel duration:(NSTimeInterval)duration isInDetail:(BOOL)isInDetail;
+ (void)sendMidInsertADShowOverEventForADModel:(TTVMidInsertADModel *)adModel duration:(NSTimeInterval)duration isInDetail:(BOOL)isInDetail;
+ (void)sendRealTimeDownloadWithModel:(TTVMidInsertADModel *)adModel;
@end
