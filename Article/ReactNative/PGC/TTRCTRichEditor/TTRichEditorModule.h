//
//  TTRichEditorModule.h
//  Article
//
//  Created by liaozhijie on 2017/7/21.
//
//

#ifndef TTRichEditorModule_h
#define TTRichEditorModule_h

#import <React/RCTBridgeModule.h>
#import <React/RCTLog.h>
#import "TTIndicatorView.h"

@interface TTRichEditorModule : NSObject <RCTBridgeModule, TTImagePickerControllerDelegate>

// promise block回调
@property (nonatomic) NSMutableDictionary<NSString *, RCTPromiseResolveBlock>* resolveBlocks;
@property (nonatomic) NSMutableDictionary<NSString *, RCTPromiseRejectBlock>* rejectBlocks;
// loading view
@property (nonatomic, strong) TTIndicatorView * indicatorView;

@end

#endif /* TTRichEditorModule_h */
