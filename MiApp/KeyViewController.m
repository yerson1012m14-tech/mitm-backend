#import "KeyViewController.h"
#import "ViewController.h"

static UIColor *XFBlack(void) {
    return [UIColor colorWithRed:0.018 green:0.020 blue:0.025 alpha:1.0];
}

static UIColor *XFCard(void) {
    return [UIColor colorWithRed:0.055 green:0.060 blue:0.075 alpha:1.0];
}

static UIColor *XFAccent(void) {
    return [UIColor colorWithRed:0.43 green:0.24 blue:1.0 alpha:1.0];
}

static UIColor *XFAccent2(void) {
    return [UIColor colorWithRed:0.20 green:0.78 blue:1.0 alpha:1.0];
}

@interface KeyViewController () <UITextFieldDelegate>

@property(nonatomic,strong) UIScrollView *scrollView;
@property(nonatomic,strong) UIView *contentView;
@property(nonatomic,strong) UITextField *keyField;
@property(nonatomic,strong) UIButton *pasteButton;
@property(nonatomic,strong) UIButton *continueButton;
@property(nonatomic,strong) UILabel *statusLabel;
@property(nonatomic,strong) UIActivityIndicatorView *spinner;

@end

@implementation KeyViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = XFBlack();

    [self buildUI];
    [self registerKeyboardNotifications];

    UITapGestureRecognizer *tap =
        [[UITapGestureRecognizer alloc]
            initWithTarget:self
                    action:@selector(dismissKeyboard)];

    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];

    [self inspectClipboardSilently];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self inspectClipboardSilently];

    [self.view layoutIfNeeded];
    [self ensureKeyFieldVisible];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UI

- (void)buildUI {

    /*
     UIScrollView principal.
     Se fija al SAFE AREA para evitar recortes
     en iPhone con notch / Dynamic Island.
     */

    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollView.backgroundColor = XFBlack();

    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;

    self.scrollView.keyboardDismissMode =
        UIScrollViewKeyboardDismissModeInteractive;

    /*
     No dejamos que UIKit agregue insets automáticos
     porque nosotros controlamos los insets del teclado.
     */
    self.scrollView.contentInsetAdjustmentBehavior =
        UIScrollViewContentInsetAdjustmentNever;

    [self.view addSubview:self.scrollView];

    [NSLayoutConstraint activateConstraints:@[
        [self.scrollView.topAnchor
            constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],

        [self.scrollView.bottomAnchor
            constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],

        [self.scrollView.leadingAnchor
            constraintEqualToAnchor:self.view.leadingAnchor],

        [self.scrollView.trailingAnchor
            constraintEqualToAnchor:self.view.trailingAnchor]
    ]];

    /*
     Content view.
     IMPORTANTE:
     solamente usa contentLayoutGuide/frameLayoutGuide.
     */

    self.contentView = [[UIView alloc] init];
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    self.contentView.backgroundColor = XFBlack();

    [self.scrollView addSubview:self.contentView];

    [NSLayoutConstraint activateConstraints:@[
        [self.contentView.topAnchor
            constraintEqualToAnchor:self.scrollView.contentLayoutGuide.topAnchor],

        [self.contentView.bottomAnchor
            constraintEqualToAnchor:self.scrollView.contentLayoutGuide.bottomAnchor],

        [self.contentView.leadingAnchor
            constraintEqualToAnchor:self.scrollView.contentLayoutGuide.leadingAnchor],

        [self.contentView.trailingAnchor
            constraintEqualToAnchor:self.scrollView.contentLayoutGuide.trailingAnchor],

        [self.contentView.widthAnchor
            constraintEqualToAnchor:self.scrollView.frameLayoutGuide.widthAnchor],

        [self.contentView.heightAnchor
            constraintGreaterThanOrEqualToAnchor:self.scrollView.frameLayoutGuide.heightAnchor]
    ]];

    /*
     Glow de fondo.
     */

    UIView *glow = [[UIView alloc] init];
    glow.translatesAutoresizingMaskIntoConstraints = NO;
    glow.backgroundColor = XFAccent();
    glow.alpha = 0.14;
    glow.layer.cornerRadius = 95.0;
    glow.layer.shadowColor = XFAccent().CGColor;
    glow.layer.shadowOpacity = 0.8;
    glow.layer.shadowRadius = 40.0;
    glow.layer.shadowOffset = CGSizeZero;

    [self.contentView addSubview:glow];

    /*
     Logo.
     */

    UILabel *logo = [[UILabel alloc] init];
    logo.translatesAutoresizingMaskIntoConstraints = NO;
    logo.text = @"X";
    logo.textAlignment = NSTextAlignmentCenter;
    logo.font =
        [UIFont systemFontOfSize:58
                          weight:UIFontWeightBlack];

    logo.textColor = UIColor.whiteColor;

    logo.backgroundColor =
        [UIColor colorWithWhite:0.08 alpha:1.0];

    logo.layer.cornerRadius = 38.0;
    logo.layer.masksToBounds = YES;
    logo.layer.borderWidth = 2.0;
    logo.layer.borderColor = XFAccent().CGColor;

    [self.contentView addSubview:logo];

    /*
     Título.
     */

    UILabel *title = [[UILabel alloc] init];
    title.translatesAutoresizingMaskIntoConstraints = NO;
    title.text = @"XITFORGE";
    title.textColor = UIColor.whiteColor;

    title.font =
        [UIFont systemFontOfSize:30
                          weight:UIFontWeightBlack];

    title.textAlignment = NSTextAlignmentCenter;

    [self.contentView addSubview:title];

    /*
     Subtítulo.
     */

    UILabel *subtitle = [[UILabel alloc] init];
    subtitle.translatesAutoresizingMaskIntoConstraints = NO;
    subtitle.text = @"ACCESO SEGURO";
    subtitle.textColor = XFAccent2();

    subtitle.font =
        [UIFont monospacedSystemFontOfSize:11
                                    weight:UIFontWeightBold];

    subtitle.textAlignment = NSTextAlignmentCenter;

    [self.contentView addSubview:subtitle];

    /*
     Instrucción.
     */

    UILabel *instruction = [[UILabel alloc] init];
    instruction.translatesAutoresizingMaskIntoConstraints = NO;

    instruction.text =
        @"Copia tu Key y pégala aquí.\n"
         "Si ya está copiada, XITFORGE la detectará automáticamente.";

    instruction.textColor =
        [UIColor colorWithWhite:0.68 alpha:1.0];

    instruction.numberOfLines = 0;
    instruction.textAlignment = NSTextAlignmentCenter;

    instruction.font =
        [UIFont systemFontOfSize:14
                          weight:UIFontWeightRegular];

    [self.contentView addSubview:instruction];

    /*
     Card.
     */

    UIView *card = [[UIView alloc] init];
    card.translatesAutoresizingMaskIntoConstraints = NO;

    card.backgroundColor = XFCard();
    card.layer.cornerRadius = 18.0;
    card.layer.borderWidth = 1.0;

    card.layer.borderColor =
        [UIColor colorWithWhite:0.16 alpha:1.0].CGColor;

    [self.contentView addSubview:card];

    /*
     Label de Key.
     */

    UILabel *keyLabel = [[UILabel alloc] init];
    keyLabel.translatesAutoresizingMaskIntoConstraints = NO;

    keyLabel.text = @"KEY DE ACCESO";
    keyLabel.textColor =
        [UIColor colorWithWhite:0.62 alpha:1.0];

    keyLabel.font =
        [UIFont monospacedSystemFontOfSize:10
                                    weight:UIFontWeightBold];

    [card addSubview:keyLabel];

    /*
     Campo de Key.
     */

    self.keyField = [[UITextField alloc] init];
    self.keyField.translatesAutoresizingMaskIntoConstraints = NO;

    self.keyField.delegate = self;

    self.keyField.placeholder =
        @"XXXX-XXXX-XXXX-XXXX";

    self.keyField.textColor = UIColor.whiteColor;
    self.keyField.tintColor = XFAccent2();

    self.keyField.backgroundColor =
        [UIColor colorWithWhite:0.025 alpha:1.0];

    self.keyField.layer.cornerRadius = 12.0;
    self.keyField.layer.borderWidth = 1.0;

    self.keyField.layer.borderColor =
        [UIColor colorWithWhite:0.14 alpha:1.0].CGColor;

    self.keyField.font =
        [UIFont monospacedSystemFontOfSize:16
                                    weight:UIFontWeightBold];

    self.keyField.autocapitalizationType =
        UITextAutocapitalizationTypeAllCharacters;

    self.keyField.autocorrectionType =
        UITextAutocorrectionTypeNo;

    self.keyField.spellCheckingType =
        UITextSpellCheckingTypeNo;

    self.keyField.returnKeyType =
        UIReturnKeyDone;

    self.keyField.clearButtonMode =
        UITextFieldViewModeWhileEditing;

    self.keyField.leftView =
        [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 1)];

    self.keyField.leftViewMode =
        UITextFieldViewModeAlways;

    [self.keyField addTarget:self
                      action:@selector(keyChanged:)
            forControlEvents:UIControlEventEditingChanged];

    [card addSubview:self.keyField];

    /*
     Botón pegar.
     */

    self.pasteButton =
        [UIButton buttonWithType:UIButtonTypeSystem];

    self.pasteButton.translatesAutoresizingMaskIntoConstraints = NO;

    [self.pasteButton setTitle:@"PEGAR KEY"
                       forState:UIControlStateNormal];

    [self.pasteButton setTitleColor:XFAccent2()
                            forState:UIControlStateNormal];

    self.pasteButton.titleLabel.font =
        [UIFont monospacedSystemFontOfSize:11
                                    weight:UIFontWeightBold];

    self.pasteButton.backgroundColor =
        [UIColor colorWithWhite:0.09 alpha:1.0];

    self.pasteButton.layer.cornerRadius = 10.0;

    [self.pasteButton addTarget:self
                         action:@selector(pasteKey:)
               forControlEvents:UIControlEventTouchUpInside];

    [card addSubview:self.pasteButton];

    /*
     Botón entrar.
     */

    self.continueButton =
        [UIButton buttonWithType:UIButtonTypeSystem];

    self.continueButton.translatesAutoresizingMaskIntoConstraints = NO;

    [self.continueButton setTitle:@"VERIFICAR Y ENTRAR"
                          forState:UIControlStateNormal];

    [self.continueButton setTitleColor:UIColor.whiteColor
                               forState:UIControlStateNormal];

    self.continueButton.titleLabel.font =
        [UIFont systemFontOfSize:15
                          weight:UIFontWeightBlack];

    self.continueButton.backgroundColor = XFAccent();
    self.continueButton.layer.cornerRadius = 14.0;

    self.continueButton.layer.shadowColor =
        XFAccent().CGColor;

    self.continueButton.layer.shadowOpacity = 0.35;
    self.continueButton.layer.shadowRadius = 14.0;
    self.continueButton.layer.shadowOffset = CGSizeZero;

    [self.continueButton addTarget:self
                            action:@selector(verifyKey:)
                  forControlEvents:UIControlEventTouchUpInside];

    [self.contentView addSubview:self.continueButton];

    /*
     Estado.
     */

    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.translatesAutoresizingMaskIntoConstraints = NO;

    self.statusLabel.text =
        @"Listo para verificar";

    self.statusLabel.textColor =
        [UIColor colorWithWhite:0.55 alpha:1.0];

    self.statusLabel.font =
        [UIFont monospacedSystemFontOfSize:11
                                    weight:UIFontWeightRegular];

    self.statusLabel.textAlignment =
        NSTextAlignmentCenter;

    self.statusLabel.numberOfLines = 2;

    [self.contentView addSubview:self.statusLabel];

    /*
     Spinner.
     */

    self.spinner =
        [[UIActivityIndicatorView alloc]
            initWithActivityIndicatorStyle:
                UIActivityIndicatorViewStyleMedium];

    self.spinner.translatesAutoresizingMaskIntoConstraints = NO;

    self.spinner.color = XFAccent2();
    self.spinner.hidden = YES;

    [self.contentView addSubview:self.spinner];

    /*
     Footer.
     */

    UILabel *footer = [[UILabel alloc] init];
    footer.translatesAutoresizingMaskIntoConstraints = NO;

    footer.text =
        @"XITFORGE • ACCESO MULTIUSUARIO";

    footer.textColor =
        [UIColor colorWithWhite:0.36 alpha:1.0];

    footer.font =
        [UIFont monospacedSystemFontOfSize:9
                                    weight:UIFontWeightSemibold];

    footer.textAlignment =
        NSTextAlignmentCenter;

    [self.contentView addSubview:footer];

    /*
     Constraints.
     */

    [NSLayoutConstraint activateConstraints:@[

        [glow.topAnchor
            constraintEqualToAnchor:self.contentView.topAnchor
                           constant:20.0],

        [glow.centerXAnchor
            constraintEqualToAnchor:self.contentView.centerXAnchor],

        [glow.widthAnchor
            constraintEqualToConstant:190.0],

        [glow.heightAnchor
            constraintEqualToConstant:190.0],

        /*
         Logo
         */

        [logo.topAnchor
            constraintEqualToAnchor:self.contentView.topAnchor
                           constant:32.0],

        [logo.centerXAnchor
            constraintEqualToAnchor:self.contentView.centerXAnchor],

        [logo.widthAnchor
            constraintEqualToConstant:76.0],

        [logo.heightAnchor
            constraintEqualToConstant:76.0],

        /*
         Título
         */

        [title.topAnchor
            constraintEqualToAnchor:logo.bottomAnchor
                           constant:18.0],

        [title.leadingAnchor
            constraintEqualToAnchor:self.contentView.leadingAnchor
                           constant:24.0],

        [title.trailingAnchor
            constraintEqualToAnchor:self.contentView.trailingAnchor
                            constant:-24.0],

        /*
         Subtítulo
         */

        [subtitle.topAnchor
            constraintEqualToAnchor:title.bottomAnchor
                           constant:4.0],

        [subtitle.leadingAnchor
            constraintEqualToAnchor:title.leadingAnchor],

        [subtitle.trailingAnchor
            constraintEqualToAnchor:title.trailingAnchor],

        /*
         Instrucción
         */

        [instruction.topAnchor
            constraintEqualToAnchor:subtitle.bottomAnchor
                           constant:18.0],

        [instruction.leadingAnchor
            constraintEqualToAnchor:self.contentView.leadingAnchor
                           constant:32.0],

        [instruction.trailingAnchor
            constraintEqualToAnchor:self.contentView.trailingAnchor
                            constant:-32.0],

        /*
         Card
         */

        [card.topAnchor
            constraintEqualToAnchor:instruction.bottomAnchor
                           constant:24.0],

        [card.leadingAnchor
            constraintEqualToAnchor:self.contentView.leadingAnchor
                           constant:20.0],

        [card.trailingAnchor
            constraintEqualToAnchor:self.contentView.trailingAnchor
                            constant:-20.0],

        [card.heightAnchor
            constraintEqualToConstant:164.0],

        /*
         Label
         */

        [keyLabel.topAnchor
            constraintEqualToAnchor:card.topAnchor
                           constant:18.0],

        [keyLabel.leadingAnchor
            constraintEqualToAnchor:card.leadingAnchor
                           constant:16.0],

        /*
         Campo
         */

        [self.keyField.topAnchor
            constraintEqualToAnchor:keyLabel.bottomAnchor
                           constant:10.0],

        [self.keyField.leadingAnchor
            constraintEqualToAnchor:card.leadingAnchor
                           constant:16.0],

        [self.keyField.trailingAnchor
            constraintEqualToAnchor:card.trailingAnchor
                            constant:-16.0],

        [self.keyField.heightAnchor
            constraintEqualToConstant:48.0],

        /*
         Paste
         */

        [self.pasteButton.topAnchor
            constraintEqualToAnchor:self.keyField.bottomAnchor
                           constant:10.0],

        [self.pasteButton.leadingAnchor
            constraintEqualToAnchor:card.leadingAnchor
                           constant:16.0],

        [self.pasteButton.widthAnchor
            constraintEqualToConstant:120.0],

        [self.pasteButton.heightAnchor
            constraintEqualToConstant:32.0],

        /*
         Entrar
         */

        [self.continueButton.topAnchor
            constraintEqualToAnchor:card.bottomAnchor
                           constant:20.0],

        [self.continueButton.leadingAnchor
            constraintEqualToAnchor:self.contentView.leadingAnchor
                           constant:20.0],

        [self.continueButton.trailingAnchor
            constraintEqualToAnchor:self.contentView.trailingAnchor
                            constant:-20.0],

        [self.continueButton.heightAnchor
            constraintEqualToConstant:54.0],

        /*
         Spinner
         */

        [self.spinner.centerYAnchor
            constraintEqualToAnchor:self.continueButton.centerYAnchor],

        [self.spinner.trailingAnchor
            constraintEqualToAnchor:self.continueButton.trailingAnchor
                            constant:-16.0],

        /*
         Status
         */

        [self.statusLabel.topAnchor
            constraintEqualToAnchor:self.continueButton.bottomAnchor
                           constant:14.0],

        [self.statusLabel.leadingAnchor
            constraintEqualToAnchor:self.contentView.leadingAnchor
                           constant:30.0],

        [self.statusLabel.trailingAnchor
            constraintEqualToAnchor:self.contentView.trailingAnchor
                            constant:-30.0],

        /*
         Footer
         */

        [footer.topAnchor
            constraintEqualToAnchor:self.statusLabel.bottomAnchor
                           constant:28.0],

        [footer.leadingAnchor
            constraintEqualToAnchor:self.contentView.leadingAnchor
                           constant:20.0],

        [footer.trailingAnchor
            constraintEqualToAnchor:self.contentView.trailingAnchor
                            constant:-20.0],

        [footer.bottomAnchor
            constraintEqualToAnchor:self.contentView.bottomAnchor
                           constant:-30.0]
    ]];
}

#pragma mark - Keyboard

- (void)registerKeyboardNotifications {

    NSNotificationCenter *center =
        [NSNotificationCenter defaultCenter];

    [center addObserver:self
               selector:@selector(keyboardWillChangeFrame:)
                   name:UIKeyboardWillChangeFrameNotification
                 object:nil];

    [center addObserver:self
               selector:@selector(keyboardWillHide:)
                   name:UIKeyboardWillHideNotification
                 object:nil];
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification {

    NSDictionary *info =
        notification.userInfo;

    NSValue *frameValue =
        info[UIKeyboardFrameEndUserInfoKey];

    if (!frameValue) {
        return;
    }

    CGRect keyboardScreen =
        [frameValue CGRectValue];

    CGRect keyboardFrame =
        [self.view convertRect:keyboardScreen
                        fromView:nil];

    CGFloat overlap =
        MAX(0.0,
            CGRectGetMaxY(self.view.bounds) -
            CGRectGetMinY(keyboardFrame));

    CGFloat bottomInset =
        overlap > 0.0
        ? overlap + 20.0
        : 0.0;

    NSTimeInterval duration =
        [info[UIKeyboardAnimationDurationUserInfoKey] doubleValue];

    UIViewAnimationCurve curve =
        [info[UIKeyboardAnimationCurveUserInfoKey] integerValue];

    UIEdgeInsets inset =
        UIEdgeInsetsMake(
            0.0,
            0.0,
            bottomInset,
            0.0
        );

    [UIView beginAnimations:@"XITFORGEKeyboard"
                    context:nil];

    [UIView setAnimationDuration:duration];

    [UIView setAnimationCurve:curve];

    self.scrollView.contentInset = inset;
    self.scrollView.scrollIndicatorInsets = inset;

    [UIView commitAnimations];

    [self ensureKeyFieldVisible];
}

- (void)keyboardWillHide:(NSNotification *)notification {

    NSDictionary *info =
        notification.userInfo;

    NSTimeInterval duration =
        [info[UIKeyboardAnimationDurationUserInfoKey] doubleValue];

    [UIView animateWithDuration:duration
                     animations:^{

        self.scrollView.contentInset =
            UIEdgeInsetsZero;

        self.scrollView.scrollIndicatorInsets =
            UIEdgeInsetsZero;
    }];
}

- (void)ensureKeyFieldVisible {

    if (!self.keyField.isFirstResponder) {
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{

        CGRect rect =
            [self.scrollView
                convertRect:self.keyField.bounds
                  fromView:self.keyField];

        rect =
            CGRectInset(rect, 0.0, -35.0);

        [self.scrollView
            scrollRectToVisible:rect
                       animated:YES];
    });
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

#pragma mark - Key Formatting

- (NSString *)formattedKeyFromString:(NSString *)input {

    if (!input) {
        return @"";
    }

    NSString *clean =
        [input stringByTrimmingCharactersInSet:
            [NSCharacterSet whitespaceAndNewlineCharacterSet]];

    clean =
        [clean uppercaseString];

    clean =
        [[clean componentsSeparatedByString:@"-"]
            componentsJoinedByString:@""];

    NSMutableString *allowed =
        [NSMutableString string];

    for (NSUInteger i = 0;
         i < clean.length && allowed.length < 16;
         i++) {

        unichar ch =
            [clean characterAtIndex:i];

        BOOL isLetter =
            ((ch >= 'A' && ch <= 'Z') ||
             (ch >= 'a' && ch <= 'z'));

        BOOL isNumber =
            (ch >= '0' && ch <= '9');

        if (isLetter || isNumber) {

            [allowed appendFormat:@"%C", ch];
        }
    }

    NSMutableString *formatted =
        [NSMutableString string];

    for (NSUInteger i = 0;
         i < allowed.length;
         i++) {

        if (i > 0 && i % 4 == 0) {
            [formatted appendString:@"-"];
        }

        [formatted appendFormat:@"%C",
            [allowed characterAtIndex:i]];
    }

    return formatted;
}

- (void)keyChanged:(UITextField *)field {

    NSString *formatted =
        [self formattedKeyFromString:field.text];

    field.text = formatted;

    if (formatted.length == 19) {

        self.statusLabel.text =
            @"✓ Key lista para verificar";

        self.statusLabel.textColor =
            XFAccent2();

    } else {

        self.statusLabel.text =
            @"Completa los 16 caracteres de la Key";

        self.statusLabel.textColor =
            [UIColor colorWithWhite:0.55 alpha:1.0];
    }
}

#pragma mark - Clipboard

- (void)inspectClipboardSilently {

    NSString *clipboard =
        [UIPasteboard generalPasteboard].string;

    if (clipboard.length == 0) {
        return;
    }

    NSString *formatted =
        [self formattedKeyFromString:clipboard];

    if (formatted.length == 19) {

        self.keyField.text = formatted;

        self.statusLabel.text =
            @"✓ Key detectada en el portapapeles";

        self.statusLabel.textColor =
            XFAccent2();
    }
}

- (void)pasteKey:(id)sender {

    [self dismissKeyboard];

    NSString *clipboard =
        [UIPasteboard generalPasteboard].string;

    if (clipboard.length == 0) {

        self.statusLabel.text =
            @"No hay ninguna Key copiada";

        self.statusLabel.textColor =
            [UIColor systemOrangeColor];

        return;
    }

    self.keyField.text = clipboard;

    [self keyChanged:self.keyField];

    if (self.keyField.text.length == 19) {

        self.statusLabel.text =
            @"✓ Key pegada. Lista para verificar";

        self.statusLabel.textColor =
            XFAccent2();
    }
}

#pragma mark - Text Field

- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    [self dismissKeyboard];

    return YES;
}

#pragma mark - Verification

- (void)verifyKey:(id)sender {

    [self dismissKeyboard];

    NSString *key =
        [self formattedKeyFromString:self.keyField.text];

    if (key.length != 19) {

        self.statusLabel.text =
            @"✕ Key inválida o incompleta";

        self.statusLabel.textColor =
            [UIColor systemRedColor];

        return;
    }

    self.continueButton.enabled = NO;
    self.pasteButton.enabled = NO;

    self.spinner.hidden = NO;
    [self.spinner startAnimating];

    self.statusLabel.text =
        @"Verificando Key…";

    self.statusLabel.textColor =
        XFAccent2();

    /*
     PUNTO PARA EL BACKEND REAL DE XITFORGE.

     Aquí posteriormente irá:

     POST /api/keys/validate

     {
         "key": "XXXX-XXXX-XXXX-XXXX"
     }

     El servidor deberá devolver algo como:

     {
         "valid": true
     }

     Solamente con valid == true
     se debe ejecutar openMainApp.
     */

    dispatch_after(
        dispatch_time(DISPATCH_TIME_NOW,
                      (int64_t)(0.45 * NSEC_PER_SEC)),
        dispatch_get_main_queue(),
        ^{

            [self.spinner stopAnimating];
            self.spinner.hidden = YES;

            self.continueButton.enabled = YES;
            self.pasteButton.enabled = YES;

            /*
             Prueba local.
             */

            self.statusLabel.text =
                @"✓ Key aceptada. Entrando a XITFORGE…";

            self.statusLabel.textColor =
                [UIColor systemGreenColor];

            [self performSelector:@selector(openMainApp)
                       withObject:nil
                       afterDelay:0.35];
        });
}

#pragma mark - Main App

- (void)openMainApp {

    ViewController *mainViewController =
        [[ViewController alloc] init];

    [self.navigationController
        setViewControllers:@[mainViewController]
                  animated:YES];
}

@end
