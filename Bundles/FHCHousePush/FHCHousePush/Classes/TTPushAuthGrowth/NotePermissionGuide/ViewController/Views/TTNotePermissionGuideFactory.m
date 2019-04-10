
//
//  TTNotePermissionGuideFactory.m
//  Article
//
//  Created by liuzuopeng on 02/07/2017.
//
//

#import "TTNotePermissionGuideFactory.h"
#import "TTNotePermissionGuideStyle1View.h"
#import "TTNotePermissionGuideStyle2View.h"



@implementation TTNotePermissionGuideFactory

+ (TTNotePermissonGuideView *)permissionGuideViewForStyle:(TTNotePermissionGuideStyle)style
{
    switch (style) {
        case TTNotePermissionGuideStyle1: {
            return [TTNotePermissionGuideStyle1View new];
        }
            break;
            
        case TTNotePermissionGuideStyle2: {
            return [TTNotePermissionGuideStyle2View new];
        }
            break;
            
        default:
            break;
    }
    return nil;
}

@end
