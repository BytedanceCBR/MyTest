//
//  TTShareProvider.h
//  Pods
//
//  Created by muhuai on 2017/5/7.
//
//

#import <Foundation/Foundation.h>
extern NSString * const TTActivityTypeCommentStat;
extern NSString * const TTActivityTypeDelete;
extern NSString * const TTActivityTypeEditting;
extern NSString * const TTActivityTypeFavourite;
extern NSString * const TTActivityTypeSetFont;
extern NSString * const TTActivityTypeForwardWeitoutiao;
extern NSString * const TTActivityTypeMessage;
extern NSString * const TTActivityTypeChangeNightMode;
extern NSString * const TTActivityTypeReportt;

@protocol TTActivityContentItemProtocol;

@protocol TTShareProvider <NSObject>

- (id<TTActivityContentItemProtocol>)adPromotionItemWithTitle:(NSString *)title iconURL:(NSString *)url;

- (id<TTActivityContentItemProtocol>)commentStatItem;

- (id<TTActivityContentItemProtocol>)deleteItem;

- (id<TTActivityContentItemProtocol>)editItem;

- (id<TTActivityContentItemProtocol>)favoriteItem;

- (id<TTActivityContentItemProtocol>)fontSettingItem;

- (id<TTActivityContentItemProtocol>)forwardItem;

- (id<TTActivityContentItemProtocol>)nightModelItem;

- (id<TTActivityContentItemProtocol>)reportItem;

- (id<TTActivityContentItemProtocol>)messageItem;

@end
