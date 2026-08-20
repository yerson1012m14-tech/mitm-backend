#import "AppDelegate.h"
#import "ViewController.h"
#import "KeyViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    UIColor *acento = [UIColor colorWithRed:0.43 green:0.24 blue:1.0 alpha:1.0];

    UINavigationBarAppearance *ap = [[UINavigationBarAppearance alloc] init];
    [ap configureWithOpaqueBackground];
    ap.backgroundColor = [UIColor blackColor];
    ap.shadowColor = [UIColor colorWithWhite:0.25 alpha:1.0];
    ap.titleTextAttributes = @{
        NSForegroundColorAttributeName: acento,
        NSFontAttributeName: [UIFont systemFontOfSize:17 weight:UIFontWeightBold]
    };
    [[UINavigationBar appearance] setStandardAppearance:ap];
    [[UINavigationBar appearance] setScrollEdgeAppearance:ap];
    [[UINavigationBar appearance] setTintColor:acento];

    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    KeyViewController *vc = [[KeyViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.navigationBarHidden = YES;
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];

    return YES;
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return UIInterfaceOrientationMaskPortrait;
}

@end
