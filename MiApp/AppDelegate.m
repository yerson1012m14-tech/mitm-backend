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

    appearance.backgroundColor =
        [UIColor blackColor];

    appearance.shadowColor =
        [UIColor colorWithWhite:0.18 alpha:1.0];

    appearance.titleTextAttributes = @{
        NSForegroundColorAttributeName: UIColor.whiteColor,
        NSFontAttributeName:
            [UIFont systemFontOfSize:17
                              weight:UIFontWeightBold]
    };

    UINavigationBar *navigationBar =
        [UINavigationBar appearance];

    navigationBar.standardAppearance = appearance;
    navigationBar.scrollEdgeAppearance = appearance;
    navigationBar.compactAppearance = appearance;
    navigationBar.tintColor = acento;

    /*
     IMPORTANTE:
     Crear la ventana con UIScreen ya no es suficiente
     en dispositivos modernos si queremos controlar
     correctamente los límites de la aplicación.
     */

    self.window =
        [[UIWindow alloc] initWithFrame:
            [UIScreen mainScreen].bounds];

    self.window.backgroundColor =
        [UIColor blackColor];

    KeyViewController *keyViewController =
        [[KeyViewController alloc] init];

    UINavigationController *navigationController =
        [[UINavigationController alloc]
            initWithRootViewController:keyViewController];

    navigationController.navigationBarHidden = YES;

    self.window.rootViewController =
        navigationController;

    [self.window makeKeyAndVisible];

    return YES;
}

#pragma mark - Orientation

- (UIInterfaceOrientationMask)application:(UIApplication *)application
    supportedInterfaceOrientationsForWindow:(UIWindow *)window {

    return UIInterfaceOrientationMaskPortrait;
}

@end
