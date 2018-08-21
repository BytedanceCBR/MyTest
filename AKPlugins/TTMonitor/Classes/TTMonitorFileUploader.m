//
//  TTMonitorFileUploader.m
//  TTMonitor
//
//  Created by bytedance on 2017/10/24.
//

#import "TTMonitorFileUploader.h"
#import "TTMonitor.h"
#import "TTMonitorConfiguration.h"
#import "TTExtensions.h"

#define BOUNDARY @"ddasdfasdfas"
#define NEW_LINE [[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]

static NSMutableArray *uploadFileList;
static NSMutableArray *sendedList;


@implementation TTMonitorFileUploader

+ (TTMonitorFileUploader *)sharedUploader
{
    static TTMonitorFileUploader *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+(void)uploadIfNeeded:(NSArray *)fileList{
    if (!fileList || ![fileList isKindOfClass:[NSArray class]]) {
        return;
    }
    if (!uploadFileList) {
        uploadFileList = [fileList mutableCopy];
        [self startSend];
    }else{
        for(NSString * filePath in fileList){
            if (![sendedList containsObject:filePath]) {
                [uploadFileList addObject:filePath];
            }
        }
        [self startSend];
    }
}

+(void)startSend{
    for(NSString * filePath in uploadFileList){
        NSString * homePath = NSHomeDirectory();
        if (!sendedList) {
            sendedList = [[NSMutableArray alloc] init];
        }
        [sendedList addObject:filePath];
        [self uploadWithFile:[homePath stringByAppendingPathComponent:filePath]];
    }
    [uploadFileList removeAllObjects];
}

+ (void)uploadWithFile:(NSString *)filePath{
    //    [self uploadTest:filePath];
    //    return;
    if (!filePath || ![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return;
    }
    NSDictionary * attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
    if ([attributes fileSize]>1024*1024*3) {
        if ([TTExtensions networkStatus]!=MNReachableViaWWAN) {
            return;
        }
    }
    NSString *deviceID = [[(TTMonitorConfiguration *)[TTMonitorConfiguration shareManager] params] valueForKey:@"device_id"];
    NSString * appID = [TTExtensions ssAppID];
    NSString * platForm = @"iphone";
    
    NSString * uploadUrlStr = [NSString stringWithFormat:@"http://amfr.snssdk.com/file_report/upload?device_id=%@&aid=%@&device_platform=%@",deviceID,appID,platForm];
    NSURL *url = [NSURL URLWithString:uploadUrlStr];
    
    //2 request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    [request setValue:[NSString stringWithFormat:@"multipart/form-data;boundary=%@",BOUNDARY] forHTTPHeaderField:@"Content-Type"];
    //  [request setValue:@"no-cache" forHTTPHeaderField:@"cache-control"];
    
    // [request setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    
    
    NSMutableData *data = [[NSMutableData alloc] init];
    
    [data appendData:[[NSString stringWithFormat:@"--%@",BOUNDARY] dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:NEW_LINE];
    [data appendData:[@"Content-Disposition: form-data; name=\"file\"; filename=\"tracelog.txt\"" dataUsingEncoding:NSUTF8StringEncoding]];
  //[data appendData:NEW_LINE];
  //[data appendData:[@"Content-Type:multipart/form-data;boundary=ddasdfasdfas" dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:NEW_LINE];
    [data appendData:NEW_LINE];
    NSData * fileData = [NSData dataWithContentsOfFile:filePath];
    [data appendData:fileData];
    [data appendData:NEW_LINE];
    [data appendData:[[NSString stringWithFormat:@"--%@--",BOUNDARY] dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:nil];
    // [request setHTTPBody:data];
    
    NSURLSessionDataTask * uploadTask = [session uploadTaskWithRequest:request fromData:data completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString * responseStr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (response) {
            NSLog(@"response=%@",responseStr);
        }
    }];
    [uploadTask resume];
}

@end
