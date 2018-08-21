//
//  TSVDownloadPromotionModel.h
//  HTSVideoPlay
//
//  Created by 邱鑫玥 on 2017/9/12.
//

#import <JSONModel/JSONModel.h>
#import "TTImageInfosModel.h"

@interface TSVDownloadPromotionModel : JSONModel

@property (nonatomic, copy)   NSString<Optional>* appDownloadText;
@property (nonatomic, strong) TTImageInfosModel<Optional>* coverImage;
@property (nonatomic, strong) NSNumber<Optional>* cellStyle;
@property (nonatomic, copy)   NSString<Optional>* groupSource;

@end
