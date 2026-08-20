#import "AppDelegate.h"
#import "ViewController.h"
#import "KeyViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    UIColor *acento =
        [UIColor colorWithRed:0.43
                        green:0.24
                         blue:1.0
                        alpha:1.0];

    UINavigationBarAppearance *appearance =
        [[UINavigationBarAppearance alloc] init];

    [appearance configureWithOpaqueBackground];

    appearance.backgroundColor = UIColor.blackColor;
    appearance.shadowColor =
        [UIColor colorWithWhite:0.25 alpha:1.0];

    appearance.titleTextAttributes = @{
        NSForegroundColorAttributeName: acento,
        NSFontAttributeName:
            [UIFont fontWithName:@"Menlo-Bold" size:17.0]
    };

    UINavigationBar *navigationBar =
        [UINavigationBar appearance];

    navigationBar.standardAppearance = appearance;
    navigationBar.scrollEdgeAppearance = appearance;
    navigationBar.tintColor = acento;

    self.window =
        [[UIWindow alloc] initWithFrame:
            [UIScreen mainScreen].bounds];

    KeyViewController *viewController =
        [[KeyViewController alloc] init];

    UINavigationController *navigationController =
        [[UINavigationController alloc]
            initWithRootViewController:viewController];

    self.window.rootViewController = navigationController;

    [self.window makeKeyAndVisible];

    return YES;
}

@end
