#import "HuntViewController.h"
#import "MainMenuViewController.h"
#import "ECSlidingViewController.h"

@interface HuntViewController ()

- (IBAction)btnMenuClicked:(id)sender;

@end

@implementation HuntViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	if (![self.slidingViewController.underLeftViewController isKindOfClass:[MainMenuViewController class]]) {
        self.slidingViewController.underLeftViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
    }
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnMenuClicked:(id)sender {
    [self.slidingViewController anchorTopViewTo:ECRight];
}

@end
