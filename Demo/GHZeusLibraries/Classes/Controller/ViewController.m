//
//  ViewController.m
//  GHZeusLibraries
//
//  Created by 张冠华 on 16/2/23.
//  Copyright © 2016年 张冠华. All rights reserved.
//

#import "ViewController.h"
#import "GHViewModel.h"
#import "DatasObj.h"
#import "GHTestDemoViewModel.h"
#import "GHStatistics.h"
#import <WebKit/WebKit.h>
#import "TMCache.h"

@interface ViewController ()
@property (nonatomic,strong) GHViewModel * network_;
@property (nonatomic,strong) GHTestDemoViewModel    *viewModel;
@property (nonatomic,strong) WKWebView  * webView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self ErrorHandLibTest];
}

- (void)ErrorHandLibTest
{
    NSArray *arr = [NSArray array];
//    NSString *string = arr[1];
   NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
   NSDictionary *deviceinfo =  [userDefaults valueForKey:@"DeviceAndAppInfoKey"];
   NSDictionary *errorinfo =  [userDefaults valueForKey:@"ErrorDetailInfoKey"];
    
    NSLog(@"设备信息：%@,错误信息：%@",deviceinfo,errorinfo);
}

- (void)networkLibTest
{
    [self performSelector:@selector(send) withObject:nil afterDelay:1.0f];
    [GHStatistics event:@"event~!@!@!@!@"];
    [GHStatistics event:@"labelEvent" label:@"test~Two"];
}

- (void)send
{
    self.viewModel =[GHTestDemoViewModel shareViewModel];
//
//    
//    GHSessionTask * task_ = [GHSessionTask taskWithMethod:@"GET"
//                                                     path:@"/subject/recommend/1/2"
//                                                   params:nil
//                                                 delegate:self.viewModel
//                                              requestType:@"xxx"];
//    task_.importCacheOnce=NO;
//    task_.dataClassName = GHTestJsonParserDataObjSample;
//    
    GHUploadSessionTask * dtask_ = [GHUploadSessionTask taskForFileUrl:@"http://k.youku.com/player/getFlvPath/sid/445654568116820f644d0_01/st/flv/fileid/030002030156C9C744D25217EBC35F01752759-6EF0-1293-DA98-24F38CCD028F?K=02f5560ea21b6a79282b372c&hd=0&ts=321&ymovie=1&r=/3sLngL0Q6CXymAIiF9JUfR5MDecwxp/gSVk/o8apWJ3KUkaGrqktKh7cO9ZZoqYN5iGQUM9dNrj6YzDV+fl4Ewr4W5iY4X9lEgp5Vo78HczSkQlDKNptYIyb4E/gyNJqcoRJ8U6kqKKIoOp8Ei94C9D5Jg2MI0ix1Za2ptrJbk=&oip=974542380&sid=445654568116820f644d0&token=5266&did=5ae168d2e840531fee13bf251f4a2811&ev=1&ctype=20&ep=HZtptIb3X5TS2YG9rcFUADm3l47umWPjuXUTbHBUAI6zcHtMS%2Fr74%2BKNEvJEeAogjUFPCAJwg6wSsF%2F8oY5yklUOmrho5O9TPV0l2FYYX7CSXpiSIO0Ljr21ATDDOuDz"
                                                              savePath:GHPathCache
                                                              fileName:@"1.flv" sessisonDelegate:self.viewModel];
//
    GHUploadSessionTask * dtask_one = [GHUploadSessionTask taskForFileUrl:@"http://k.youku.com/player/getFlvPath/sid/445654568116820f644d0_01/st/flv/fileid/030002030156C9C744D25217EBC35F01752759-6EF0-1293-DA98-24F38CCD028F?K=02f5560ea21b6a79282b372c&hd=0&ts=321&ymovie=1&r=/3sLngL0Q6CXymAIiF9JUfR5MDecwxp/gSVk/o8apWJ3KUkaGrqktKh7cO9ZZoqYN5iGQUM9dNrj6YzDV+fl4Ewr4W5iY4X9lEgp5Vo78HczSkQlDKNptYIyb4E/gyNJqcoRJ8U6kqKKIoOp8Ei94C9D5Jg2MI0ix1Za2ptrJbk=&oip=974542380&sid=445654568116820f644d0&token=5266&did=5ae168d2e840531fee13bf251f4a2811&ev=1&ctype=20&ep=HZtptIb3X5TS2YG9rcFUADm3l47umWPjuXUTbHBUAI6zcHtMS%2Fr74%2BKNEvJEeAogjUFPCAJwg6wSsF%2F8oY5yklUOmrho5O9TPV0l2FYYX7CSXpiSIO0Ljr21ATDDOuDz"
                                                              savePath:GHPathCache
                                                              fileName:@"2.flv" sessisonDelegate:self.viewModel];

    
    [self.viewModel downloadTask:dtask_ progress:^(NSProgress *downloadProgress)
    {
        NSLog(@"%lld",downloadProgress.completedUnitCount);
    } Block:^(GHSessionTask *session, NSError *error)
    {
        NSLog(@"%@",session.downloadDataPath);
    }];

    [self.viewModel downloadTask:dtask_one progress:^(NSProgress *downloadProgress){
        NSLog(@"222=======>%lld",downloadProgress.completedUnitCount);
    } Block:^(GHSessionTask *session, NSError *error)
     {
         NSLog(@"%@",session.downloadDataPath);
    }];
    
//    NSLog(@"%d",task_.importCacheOnce);
//    [self.viewModel sendTask:task_];
//
//    [self performSelector:@selector(send1:) withObject:self.network_ afterDelay:2.0f];
}

//- (void)send1:(id)sender
//{
//    NSLog(@"%@",sender);
//}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [GHStatistics beganSetTimeForPage:@"TestPage" isaHashKey:[self hash]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [GHStatistics endSetTimeForPage:@"TestPage" isaHashKey:[self hash]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
