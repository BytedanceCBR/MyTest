//
//  AKImageAlertModel.h
//  Article
//
//  Created by chenjiesheng on 2018/3/8.
//

#import "TTInterfaceTipBaseModel.h"

@interface AKImageAlertModel : TTInterfaceTipBaseModel

@property (nonatomic, copy)NSString             *imageURL;
@property (nonatomic, strong)UIImage            *image;
@property (nonatomic, copy)void(^imageViewClickBlock)(void);
@property (nonatomic, copy)void(^closeButtonClickBlock)(void);

@end
