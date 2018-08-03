//
//  TTAssetWrapper.m
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

#import "TTAssetWrapper.h"

@implementation TTAssetWrapper

@synthesize asset = _asset;
@synthesize selected = _selected;

+ (TTAssetWrapper *)wrapperWithAsset:(ALAsset *)asset
{
    TTAssetWrapper *wrapper = [[TTAssetWrapper alloc] initWithAsset:asset];
    return wrapper;
}

- (id)initWithAsset:(ALAsset *)asset
{
    if ((self = [super init])) {
        _type = TTAssetWrapperTypeAsset;
        _asset = asset;
    }
    return self;
}

- (id)initCameraType {
    if (self = [super init]) {
        _type = TTAssetWrapperTypeCamera;
    }
    return self;
}

@end
