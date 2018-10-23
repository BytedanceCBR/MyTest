//
//  TTVRelatedVideoItem+TTVDetailRelatedADInfoDataProtocol.h
//  Article
//
//  Created by pei yun on 2017/6/4.
//
//

#import <TTVideoService/VideoInformation.pbobjc.h>
#import "TTVDetailRelatedADInfoDataProtocol.h"

@interface TTVRelatedVideoItem (TTVDetailRelatedADInfoDataProtocol) <TTVDetailRelatedADInfoDataProtocol>

@property (nonatomic, strong, nullable, readonly) NSString *card_type;
@property (nonatomic, strong, nullable, readonly) NSString *show_tag;
@property (nonatomic, strong, nullable, readonly) NSString *source;
@property (nonatomic, strong, nullable, readonly) NSString *title;
@property (nonatomic, strong, nullable, readonly) NSString *creative_type;
@property (nonatomic, strong, nullable, readonly) TTImageInfosModel *middleImageInfosModel;
@property (nonatomic, strong, nullable, readonly) NSString *button_text;
@property (nonatomic, strong, nullable, readonly) NSString *uniqueIDStr;
@property (nonatomic, assign, readonly) int32_t ui_type;

- (TTAdVideoRelateAdModel *_Nullable)adModel;

@end
