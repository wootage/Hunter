#import "LoginViewController.h"
#import "MainMenuViewController.h"
#import "ECSlidingViewController.h"
#import "ApiCalls.h"
#import "Alert.h"

@interface LoginViewController () {
    
    __weak IBOutlet UITextField *txtPassword;
    __weak IBOutlet UITextField *txtUsername;
    __weak IBOutlet UILabel *lblLog;
    __weak NSUserDefaults *saved;
}
- (IBAction)btnMenuClicked:(id)sender;
- (IBAction)btnLoginClicked:(id)sender;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	if (![self.slidingViewController.underLeftViewController isKindOfClass:[MainMenuViewController class]]) {
        self.slidingViewController.underLeftViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
    }
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
    
    saved = [NSUserDefaults standardUserDefaults];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(resignAll)];
    
    [self.view addGestureRecognizer:tap];

    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(gameVersionSuccess:)
                                                 name: @"getGameVersionSuccess"
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gameVersionFail:)
                                                 name:@"getGameVersionFail"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(loginSuccess:)
                                                 name: @"loginSuccess"
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(loginFail:)
                                                 name: @"loginFail"
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(huntSuccess:)
                                                 name: @"huntSuccess"
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(huntFail:)
                                                 name: @"huntFail"
                                               object: nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"getGameVersionSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"getGameVersionFail" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"loginSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"loginFail" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"huntSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"huntFail" object:nil];
}

#pragma mark - Buttons

- (IBAction)btnMenuClicked:(id)sender {
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (IBAction)btnLoginClicked:(id)sender {
    [[ApiCalls sharedClient]getGameVersion];
}

- (void)resignAll {
    [txtUsername resignFirstResponder];
    [txtPassword resignFirstResponder];
}

#pragma mark - Notification actions

- (void) gameVersionSuccess :(NSNotification *)anote {
    
    NSDictionary *response = [anote userInfo];
    
    NSString *gameVersion = [response objectForKey:@"game_version"];
    
    [saved setObject:gameVersion forKey:@"game_version"];
    //[[ApiCalls sharedClient]hunt];
    [[ApiCalls sharedClient]login:txtUsername.text:txtPassword.text];
}

- (void) gameVersionFail :(NSNotification *)anote {
    NSLog(@"fail");
    //TODO
}

- (void)loginSuccess :(NSNotification *)anote {
    NSDictionary *response = [anote userInfo];
    
    NSString *loginToken = [response objectForKey:@"login_token"];
    
    [saved setObject:loginToken forKey:@"login_token"];
    [saved setObject:@"true" forKey:@"isLogged"];
    [lblLog setText:@"You are logged in,minimize the app and let the hunt begin"];
}

- (void)loginFail:(NSNotification *)anote {
    NSDictionary *response = [anote userInfo];
    NSString *jsonResponse = [response objectForKey:@"NSLocalizedRecoverySuggestion"];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData: [jsonResponse dataUsingEncoding:NSUTF8StringEncoding]
                                                         options: NSJSONReadingMutableContainers
                                                           error: nil];
    NSDictionary *errors = [json objectForKey:@"error"];
    NSString *errorMessage = [errors objectForKey:@"message"];

    [lblLog setText:errorMessage];    
}

- (void)huntSuccess :(NSNotification *)anote {
   /* NSDictionary *response = [anote userInfo];
    NSDictionary *jsonResponse = [response objectForKey:@"user"];
    NSArray *journal = [jsonResponse objectForKey:@"journals"];*/
    
    [saved setObject:@"900" forKey:@"timeRemining"];
    [saved synchronize];
    
     //NSLog(@"hurn sounded ");
    
    [[NSNotificationCenter defaultCenter] postNotificationName: @"prepareToHunt" object: nil userInfo:nil];
}

- (void)huntFail :(NSNotification *)anote {
    
    NSDictionary *response = [anote userInfo];
    NSString *jsonResponse = [response objectForKey:@"NSLocalizedRecoverySuggestion"];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData: [jsonResponse dataUsingEncoding:NSUTF8StringEncoding]
                                                         options: NSJSONReadingMutableContainers
                                                           error: nil];
    NSDictionary *errors = [json objectForKey:@"error"];
    NSString *errorMessage = [errors objectForKey:@"message"];
    
    
    NSDictionary *user = [json objectForKey:@"user"];
    NSString *timeRemining = [user objectForKey:@"next_activeturn_seconds"];
    
    [saved setObject:timeRemining forKey:@"timeRemining"];
    
    if ([errorMessage isEqualToString:@"An active session is required."]) {
        [saved setObject:@"false" forKey:@"isLogged"];
    }
    
    [saved synchronize];    
    
    //NSLog(@"%@",errorMessage);
    
    [[NSNotificationCenter defaultCenter] postNotificationName: @"prepareToHunt" object: nil userInfo:nil];
       //Possible errors :
    //You are out of bait.
    //You have recently been on a hunt.
    //An active session is required.
}

@end
