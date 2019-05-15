//
//  TTCertificationPreviewView.h
//  Article
//
//  Created by wangdi on 2017/5/21.
//
//

#import "SSThemed.h"

@interface TTCertificationPreviewView : SSThemedView
@property (nonatomic, assign) BOOL certificationV;

- (void)setPreViewText:(NSString *)text;
- (void)setAuthType:(NSString *)authType;

@end
