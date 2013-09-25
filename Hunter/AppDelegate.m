#import "AppDelegate.h"
#import "ApiCalls.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {

    UIBackgroundTaskIdentifier bgTask = 0;
    UIApplication  *app = [UIApplication sharedApplication];
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:bgTask];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(prepareToHunt)
                                                 name: @"prepareToHunt"
                                               object: nil];
    
    [self hunt];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"prepareToHunt" object:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [_timer invalidate];
}

- (void)prepareToHunt {
    
    NSUserDefaults *saved = [NSUserDefaults standardUserDefaults];
    NSString *isLogged = [saved objectForKey:@"isLogged"];
    int remining = [[saved objectForKey:@"timeRemining"]intValue];
    
    if ([isLogged isEqualToString:@"false"]) {
        [_timer invalidate];
    }else {
        
        time = remining ;//+ arc4random_uniform(30) + 30;
        NSLog(@"time remining : %d",remining);
        NSLog(@"%d",time);
        _timer = [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(hunt) userInfo:nil repeats:NO];
    }
}

- (void)hunt {
    [[ApiCalls sharedClient]hunt];
}

@end
