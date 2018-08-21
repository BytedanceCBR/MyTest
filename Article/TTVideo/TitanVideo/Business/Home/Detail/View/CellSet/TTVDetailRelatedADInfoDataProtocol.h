//
//  TTVDetailRelatedADInfoDataProtocol.h
//  Article
//
//  Created by pei yun on 2017/6/2.
//
//

#ifndef TTVDetailRelatedADInfoDataProtocol_h
#define TTVDetailRelatedADInfoDataProtocol_h

@class TTAdVideoRelateAdModel;
@protocol TTVDetailRelatedADInfoDataProtocol <NSObject>

@property (nonatomic, strong, nullable, readonly) NSString *card_type;
@property (nonatomic, strong, nullable, readonly) NSString *show_tag;
@property (nonatomic, strong, nullable, readonly) NSString *source;
@property (nonatomic, strong, nullable, readonly) NSString *title;
@property (nonatomic, strong, nullable, readonly) NSString *creative_type;
@property (nonatomic, strong, nullable, readonly) TTImageInfosModel *middleImageInfosModel;
@property (nonatomic, strong, nullable, readonly) NSString *button_text;
@property (nonatomic, strong, nullable, readonly) NSString *uniqueIDStr;
@property (nonatomic, strong, nullable, readonly) NSString *ad_id;
@property (nonatomic, assign, readonly) int32_t ui_type;

- (TTAdVideoRelateAdModel *_Nullable)adModel;

@end

#endif /* TTVDetailRelatedADInfoDataProtocol_h */
