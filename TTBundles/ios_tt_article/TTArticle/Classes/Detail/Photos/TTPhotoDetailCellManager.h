//
//  TTPhotoDetailCellManager.h
//  Article
//
//  Created by ranny_90 on 2017/7/12.
//
//

#import <Foundation/Foundation.h>
#import "TTPhotoDetailCellProtocol.h"

@interface TTPhotoDetailCellManager : NSObject<TTPhotoDetailCellHelperProtocol>

+ (TTPhotoDetailCellManager *)shareManager;

@end
