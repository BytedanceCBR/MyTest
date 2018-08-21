//
//  UIImage+TTAssetModel.m
//  Article
//
//  Created by 王霖 on 2017/5/4.
//
//

#import "UIImage+TTAssetModel.h"
#import "TTAssetModel.h"
#import <objc/runtime.h>

@implementation UIImage (TTAssetModel)

- (TTAssetModel *)assetModel {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setAssetModel:(TTAssetModel *)assetModel {
    objc_setAssociatedObject(self, @selector(assetModel), assetModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
