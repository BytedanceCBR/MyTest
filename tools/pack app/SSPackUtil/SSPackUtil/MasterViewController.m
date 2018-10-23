//
//  MasterViewController.m
//  SSPackUtil
//
//  Created by Zhang Leonardo on 14-11-26.
//  Copyright (c) 2014年 leonardo. All rights reserved.
//

#import "MasterViewController.h"
#import "ZCLChannelManager.h"
#import "ZCLChannelModel.h"
#import "ZCLChannelTableCellView.h"

@interface MasterViewController ()<NSTableViewDataSource, NSTableViewDelegate>
{
    BOOL _isEditing;
}
@property(nonatomic, retain)NSMutableArray * channelIDs;
@property(nonatomic, retain)NSString * ipaPath;
@property(nonatomic, retain)NSMutableString * consoleStrings;
@end

@implementation MasterViewController

- (void)dealloc
{
    _channelListView.delegate = nil;
    _channelListView.dataSource = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [ super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.ipaPath = nil;
        self.channelIDs = [NSMutableArray arrayWithArray:[ZCLChannelManager channelIDs]];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    _channelListView.delegate = self;
    _channelListView.dataSource = self;
    [_originIPAPathLabel.cell setUsesSingleLineMode:NO];
}


- (IBAction)removeChannelButton:(id)sender {
    _isEditing = !_isEditing;
    if (_isEditing) {
        [self.removeChannelButton setTitle:@"取消删除"];
    }
    else {
        [self.removeChannelButton setTitle:@"删除渠道"];
    }
    [_channelListView reloadData];
}

- (IBAction)checkAllButtonClicked:(id)sender {
    [self changeAllChannelCheckeStaus:YES];
}

- (IBAction)uncheckAllButtonClicked:(id)sender {
    [self changeAllChannelCheckeStaus:NO];
}

- (IBAction)addChannelButtonClicked:(id)sender {
    NSString * str = [_addChannelTextField stringValue];
    NSString * trimStr = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([trimStr length] > 0) {
        if ([self containChannel:trimStr]) {
            _addChannelTextField.stringValue = @"";
            return;
        }
        [_channelIDs addObject:[ZCLChannelManager modelByChannelID:trimStr]];
        [ZCLChannelManager save:_channelIDs];
        [_channelListView reloadData];
    }
    _addChannelTextField.stringValue = @"";
}

- (IBAction)selectOriginIPAButtonClicked:(id)sender {
    
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setAllowsMultipleSelection:NO]; //设置多选模式
    [openPanel setAllowedFileTypes:@[@"ipa"]];//设置文件的默认类型
    
    [openPanel setMessage:@"请选择原始的IPA"];
    [openPanel beginSheetModalForWindow:[NSApp mainWindow] completionHandler:^(NSInteger result) {
        
        if (result == NSFileHandlingPanelOKButton)
        {
            NSURL * originIPAURL = [openPanel URL];
            _originIPAPathLabel.stringValue = [originIPAURL path];
            self.ipaPath =  [originIPAURL path];
        }
    }];
}

- (void)appendMsgToConsole:(NSString *)msg
{
    [_consoleStrings appendString:msg];
//    _consoleLabel.stringValue = _consoleStrings;
    _consoleLabel.string = _consoleStrings;
}

- (IBAction)startButtonClicked:(NSButton *)sender {
    
    self.consoleStrings = [NSMutableString stringWithCapacity:400];
    if ([_ipaPath length] == 0) {
        [self appendMsgToConsole:@"请选择原始IPA"];
        return;
    }
    NSString * appInfo = [[_appInfoLabel stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([appInfo length] == 0) {
        [self appendMsgToConsole:@"请上面输入框输入应用信息"];
        return;
    }
    
    NSMutableArray * channelIDs = [NSMutableArray arrayWithCapacity:10];
    for (int i = 0; i < [_channelIDs count]; i ++) {
        ZCLChannelModel * model = [_channelIDs objectAtIndex:i];
        if (model.checked && [model.channelID length] > 0) {
            [channelIDs addObject:model.channelID];
        }
    }
    if ([channelIDs count] == 0) {
        [self appendMsgToConsole:@"请至少选择1个渠道号"];
        return;
    }
    
    [self appendMsgToConsole:@"开始打包，请等待。。。"];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy_MM_dd_HH_mm_ss"];
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSString * dataStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:now]];
    
    for (int i = 0; i < [channelIDs count]; i ++) {
        NSString * channel = [channelIDs objectAtIndex:i];
        NSPipe *pipe = [NSPipe pipe];
        NSFileHandle *file = pipe.fileHandleForReading;
        
        NSTask *task = [[NSTask alloc] init];
        [task setLaunchPath:@"/bin/bash"];
        NSString * bashPath = [[NSBundle mainBundle] pathForResource:@"pack" ofType:@"sh"];
        NSString * ipaPath = _ipaPath;
        [task setArguments:[NSArray arrayWithObjects:bashPath, dataStr, ipaPath, channel, appInfo, nil]];
        task.standardOutput = pipe;
        [task launch];
        
        NSData *data = [file readDataToEndOfFile];
        [file closeFile];
        
        NSString *grepOutput = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
        [self appendMsgToConsole:grepOutput];
    }
    
    [self appendMsgToConsole:[NSString stringWithFormat:@"打包完成， 请在桌面查看 %@ 文件夹", dataStr]];
    
}

- (void)changeAllChannelCheckeStaus:(BOOL)check
{
    for (int i = 0; i < [_channelIDs count]; i++) {
        ZCLChannelModel * model = [_channelIDs objectAtIndex:i];
        model.checked = check;
    }
    [_channelListView reloadData];
}

- (BOOL)containChannel:(NSString *)str
{
    for (int i = 0; i < [_channelIDs count]; i++) {
        ZCLChannelModel * model = [_channelIDs objectAtIndex:i];
        if ([model.channelID isEqualToString:str]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark -- NSTableViewDataSource, NSTableViewDelegate

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    return 25;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [_channelIDs count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSTableCellView * cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    ZCLChannelModel * model = [_channelIDs objectAtIndex:row];
    NSString * statusStr = model.checked ? @"打包" : @"取消";
    if (_isEditing) {
        statusStr = @"点击删除";
    }
    NSString * str = [NSString stringWithFormat:@"%@\t\t%@", statusStr,model.channelID];
    cellView.textField.stringValue = str;
    return cellView;
}

-(void)tableViewSelectionDidChange:(NSNotification *)notification{
    NSInteger index = [[notification object] selectedRow];
    if (index >= 0 && index < [_channelIDs count]) {
        if (_isEditing) {
            [_channelIDs removeObjectAtIndex:index];
        }
        else {
            ZCLChannelModel * model = [_channelIDs objectAtIndex:index];
            model.checked = !model.checked;
            [ZCLChannelManager save:_channelIDs];
            
        }
        [_channelListView reloadData];
    }
}



@end
