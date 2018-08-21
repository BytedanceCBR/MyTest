//
//  TTAModelling.h
//  YYModel <https://github.com/ibireme/YYModel>
//
//  Created by ibireme on 15/5/10.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import <Foundation/Foundation.h>

#if __has_include(<JSONModelling/TTAModel.h>)
FOUNDATION_EXPORT double TTAModelVersionNumber;
FOUNDATION_EXPORT const unsigned char TTAModelVersionString[];
#import <JSONModelling/NSObject+TTAModel.h>
#import <JSONModelling/TTAClassInfo.h>
#else
#import "NSObject+TTAModel.h"
#import "TTAClassInfo.h"
#endif
