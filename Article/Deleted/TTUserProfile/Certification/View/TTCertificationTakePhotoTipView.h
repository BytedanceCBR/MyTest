//
//  TTCertificationTakePhotoTipView.h
//  Article
//
//  Created by wangdi on 2017/5/23.
//
//

#import "SSThemed.h"

@interface TTCertificationTakePhotoTipModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIColor *textColor;

@end

@interface TTCertificationTakePhotoTipView : SSThemedView

@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, strong) NSArray<TTCertificationTakePhotoTipModel *> *titleModels;

@end
