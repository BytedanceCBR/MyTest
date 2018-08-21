//
//  TTAssetWrapper.h
//  TTAssetPickerController
//
//  Created by Wesley Smith on 5/16/12.
//  Copyright (c) 2012 Wesley D. Smith. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "TTAssetViewColumn.h"

typedef NS_ENUM(NSUInteger, TTAssetWrapperType) {
    TTAssetWrapperTypeAsset,
    TTAssetWrapperTypeCamera,
};

@interface TTAssetWrapper : NSObject

@property (nonatomic, assign, readonly) TTAssetWrapperType type;
@property (nonatomic, strong, readonly) ALAsset *asset;
@property (nonatomic, getter = isSelected) BOOL selected;

// Extended by luohuaqing for selecting on the image preview
@property (nonatomic, weak) TTAssetViewColumn * columnView;

+ (TTAssetWrapper *)wrapperWithAsset:(ALAsset *)asset;

- (id)initWithAsset:(ALAsset *)asset;
- (id)initCameraType;

@end
