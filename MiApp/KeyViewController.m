#import "KeyViewController.h"
#import "ViewController.h"

static UIColor *XFBlack(void) { return [UIColor colorWithRed:0.018 green:0.02 blue:0.025 alpha:1.0]; }
static UIColor *XFCard(void) { return [UIColor colorWithRed:0.055 green:0.06 blue:0.075 alpha:1.0]; }
static UIColor *XFAccent(void) { return [UIColor colorWithRed:0.43 green:0.24 blue:1.0 alpha:1.0]; }
static UIColor *XFAccent2(void) { return [UIColor colorWithRed:0.20 green:0.78 blue:1.0 alpha:1.0]; }

@interface KeyViewController () <UITextFieldDelegate>
@property(nonatomic,strong) UITextField *keyField;
@property(nonatomic,strong) UIButton *pasteButton;
@property(nonatomic,strong) UIButton *continueButton;
@property(nonatomic,strong) UILabel *statusLabel;
@property(nonatomic,strong) UIActivityIndicatorView *spinner;
@end

@implementation KeyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = XFBlack();
    [self buildUI];
    [self inspectClipboardSilently];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self inspectClipboardSilently];
}

- (void)buildUI {
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scroll.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:scroll];

    UIView *content = [[UIView alloc] initWithFrame:CGRectZero];
    [scroll addSubview:content];

    NSLayoutConstraint *w = [content.widthAnchor constraintEqualToAnchor:scroll.widthAnchor];
    NSLayoutConstraint *h = [content.heightAnchor constraintGreaterThanOrEqualToAnchor:scroll.heightAnchor];
    [NSLayoutConstraint activateConstraints:@[w,h]];

    UIView *glow = [[UIView alloc] init];
    glow.translatesAutoresizingMaskIntoConstraints = NO;
    glow.backgroundColor = XFAccent();
    glow.alpha = 0.16;
    glow.layer.cornerRadius = 95;
    glow.layer.shadowColor = XFAccent().CGColor;
    glow.layer.shadowOpacity = 0.8;
    glow.layer.shadowRadius = 40;
    glow.layer.shadowOffset = CGSizeZero;
    [content addSubview:glow];

    UILabel *logo = [[UILabel alloc] init];
    logo.translatesAutoresizingMaskIntoConstraints = NO;
    logo.text = @"X";
    logo.textAlignment = NSTextAlignmentCenter;
    logo.font = [UIFont systemFontOfSize:58 weight:UIFontWeightBlack];
    logo.textColor = UIColor.whiteColor;
    logo.backgroundColor = [UIColor colorWithWhite:0.08 alpha:1.0];
    logo.layer.cornerRadius = 38;
    logo.layer.masksToBounds = YES;
    logo.layer.borderWidth = 2;
    logo.layer.borderColor = XFAccent().CGColor;
    [content addSubview:logo];

    UILabel *title = [[UILabel alloc] init];
    title.translatesAutoresizingMaskIntoConstraints = NO;
    title.text = @"XITFORGE";
    title.textColor = UIColor.whiteColor;
    title.font = [UIFont systemFontOfSize:30 weight:UIFontWeightBlack];
    title.textAlignment = NSTextAlignmentCenter;
    [content addSubview:title];

    UILabel *subtitle = [[UILabel alloc] init];
    subtitle.translatesAutoresizingMaskIntoConstraints = NO;
    subtitle.text = @"ACCESO SEGURO";
    subtitle.textColor = XFAccent2();
    subtitle.font = [UIFont monospacedSystemFontOfSize:11 weight:UIFontWeightBold];
    subtitle.textAlignment = NSTextAlignmentCenter;
    [content addSubview:subtitle];

    UILabel *instruction = [[UILabel alloc] init];
    instruction.translatesAutoresizingMaskIntoConstraints = NO;
    instruction.text = @"Copia tu Key y pégala aquí.\nSi ya está copiada, XITFORGE la detectará automáticamente.";
    instruction.textColor = [UIColor colorWithWhite:0.68 alpha:1.0];
    instruction.numberOfLines = 0;
    instruction.textAlignment = NSTextAlignmentCenter;
    instruction.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
    [content addSubview:instruction];

    UIView *card = [[UIView alloc] init];
    card.translatesAutoresizingMaskIntoConstraints = NO;
    card.backgroundColor = XFCard();
    card.layer.cornerRadius = 18;
    card.layer.borderWidth = 1;
    card.layer.borderColor = [UIColor colorWithWhite:0.16 alpha:1.0].CGColor;
    [content addSubview:card];

    UILabel *keyLabel = [[UILabel alloc] init];
    keyLabel.translatesAutoresizingMaskIntoConstraints = NO;
    keyLabel.text = @"KEY DE ACCESO";
    keyLabel.textColor = [UIColor colorWithWhite:0.62 alpha:1.0];
    keyLabel.font = [UIFont monospacedSystemFontOfSize:10 weight:UIFontWeightBold];
    [card addSubview:keyLabel];

    self.keyField = [[UITextField alloc] init];
    self.keyField.translatesAutoresizingMaskIntoConstraints = NO;
    self.keyField.delegate = self;
    self.keyField.placeholder = @"XXXX-XXXX-XXXX-XXXX";
    self.keyField.textColor = UIColor.whiteColor;
    self.keyField.tintColor = XFAccent2();
    self.keyField.backgroundColor = [UIColor colorWithWhite:0.025 alpha:1.0];
    self.keyField.layer.cornerRadius = 12;
    self.keyField.layer.borderWidth = 1;
    self.keyField.layer.borderColor = [UIColor colorWithWhite:0.14 alpha:1.0].CGColor;
    self.keyField.font = [UIFont monospacedSystemFontOfSize:16 weight:UIFontWeightBold];
    self.keyField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    self.keyField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.keyField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.keyField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0,0,12,1)];
    self.keyField.leftViewMode = UITextFieldViewModeAlways;
    [self.keyField addTarget:self action:@selector(keyChanged:) forControlEvents:UIControlEventEditingChanged];
    [card addSubview:self.keyField];

    self.pasteButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.pasteButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.pasteButton setTitle:@"PEGAR KEY" forState:UIControlStateNormal];
    [self.pasteButton setTitleColor:XFAccent2() forState:UIControlStateNormal];
    self.pasteButton.titleLabel.font = [UIFont monospacedSystemFontOfSize:11 weight:UIFontWeightBold];
    self.pasteButton.backgroundColor = [UIColor colorWithWhite:0.09 alpha:1.0];
    self.pasteButton.layer.cornerRadius = 10;
    [self.pasteButton addTarget:self action:@selector(pasteKey:) forControlEvents:UIControlEventTouchUpInside];
    [card addSubview:self.pasteButton];

    self.continueButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.continueButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.continueButton setTitle:@"VERIFICAR Y ENTRAR" forState:UIControlStateNormal];
    [self.continueButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    self.continueButton.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightBlack];
    self.continueButton.backgroundColor = XFAccent();
    self.continueButton.layer.cornerRadius = 14;
    self.continueButton.layer.shadowColor = XFAccent().CGColor;
    self.continueButton.layer.shadowOpacity = 0.35;
    self.continueButton.layer.shadowRadius = 14;
    self.continueButton.layer.shadowOffset = CGSizeZero;
    [self.continueButton addTarget:self action:@selector(verifyKey:) forControlEvents:UIControlEventTouchUpInside];
    [content addSubview:self.continueButton];

    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.statusLabel.text = @"Listo para verificar";
    self.statusLabel.textColor = [UIColor colorWithWhite:0.55 alpha:1.0];
    self.statusLabel.font = [UIFont monospacedSystemFontOfSize:11 weight:UIFontWeightRegular];
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.numberOfLines = 2;
    [content addSubview:self.statusLabel];

    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    self.spinner.translatesAutoresizingMaskIntoConstraints = NO;
    self.spinner.color = XFAccent2();
    self.spinner.hidden = YES;
    [content addSubview:self.spinner];

    UILabel *footer = [[UILabel alloc] init];
    footer.translatesAutoresizingMaskIntoConstraints = NO;
    footer.text = @"XITFORGE • ACCESO MULTIUSUARIO";
    footer.textColor = [UIColor colorWithWhite:0.36 alpha:1.0];
    footer.font = [UIFont monospacedSystemFontOfSize:9 weight:UIFontWeightSemibold];
    footer.textAlignment = NSTextAlignmentCenter;
    [content addSubview:footer];

    [NSLayoutConstraint activateConstraints:@[
        [content.topAnchor constraintEqualToAnchor:scroll.topAnchor],
        [content.bottomAnchor constraintEqualToAnchor:scroll.bottomAnchor],
        [glow.topAnchor constraintEqualToAnchor:content.topAnchor constant:30], [glow.centerXAnchor constraintEqualToAnchor:content.centerXAnchor], [glow.widthAnchor constraintEqualToConstant:190], [glow.heightAnchor constraintEqualToConstant:190],
        [logo.topAnchor constraintEqualToAnchor:content.topAnchor constant:42], [logo.centerXAnchor constraintEqualToAnchor:content.centerXAnchor], [logo.widthAnchor constraintEqualToConstant:76], [logo.heightAnchor constraintEqualToConstant:76],
        [title.topAnchor constraintEqualToAnchor:logo.bottomAnchor constant:18], [title.leadingAnchor constraintEqualToAnchor:content.leadingAnchor constant:24], [title.trailingAnchor constraintEqualToAnchor:content.trailingAnchor constant:-24],
        [subtitle.topAnchor constraintEqualToAnchor:title.bottomAnchor constant:4], [subtitle.leadingAnchor constraintEqualToAnchor:title.leadingAnchor], [subtitle.trailingAnchor constraintEqualToAnchor:title.trailingAnchor],
        [instruction.topAnchor constraintEqualToAnchor:subtitle.bottomAnchor constant:18], [instruction.leadingAnchor constraintEqualToAnchor:content.leadingAnchor constant:32], [instruction.trailingAnchor constraintEqualToAnchor:content.trailingAnchor constant:-32],
        [card.topAnchor constraintEqualToAnchor:instruction.bottomAnchor constant:24], [card.leadingAnchor constraintEqualToAnchor:content.leadingAnchor constant:20], [card.trailingAnchor constraintEqualToAnchor:content.trailingAnchor constant:-20], [card.heightAnchor constraintEqualToConstant:164],
        [keyLabel.topAnchor constraintEqualToAnchor:card.topAnchor constant:18], [keyLabel.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:16],
        [self.keyField.topAnchor constraintEqualToAnchor:keyLabel.bottomAnchor constant:10], [self.keyField.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:16], [self.keyField.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-16], [self.keyField.heightAnchor constraintEqualToConstant:48],
        [self.pasteButton.topAnchor constraintEqualToAnchor:self.keyField.bottomAnchor constant:10], [self.pasteButton.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:16], [self.pasteButton.widthAnchor constraintEqualToConstant:120], [self.pasteButton.heightAnchor constraintEqualToConstant:32],
        [self.continueButton.topAnchor constraintEqualToAnchor:card.bottomAnchor constant:20], [self.continueButton.leadingAnchor constraintEqualToAnchor:content.leadingAnchor constant:20], [self.continueButton.trailingAnchor constraintEqualToAnchor:content.trailingAnchor constant:-20], [self.continueButton.heightAnchor constraintEqualToConstant:54],
        [self.spinner.centerYAnchor constraintEqualToAnchor:self.continueButton.centerYAnchor], [self.spinner.trailingAnchor constraintEqualToAnchor:self.continueButton.trailingAnchor constant:-16],
        [self.statusLabel.topAnchor constraintEqualToAnchor:self.continueButton.bottomAnchor constant:14], [self.statusLabel.leadingAnchor constraintEqualToAnchor:content.leadingAnchor constant:30], [self.statusLabel.trailingAnchor constraintEqualToAnchor:content.trailingAnchor constant:-30],
        [footer.topAnchor constraintEqualToAnchor:self.statusLabel.bottomAnchor constant:28], [footer.leadingAnchor constraintEqualToAnchor:content.leadingAnchor constant:20], [footer.trailingAnchor constraintEqualToAnchor:content.trailingAnchor constant:-20], [footer.bottomAnchor constraintEqualToAnchor:content.bottomAnchor constant:-30]
    ]];
}

- (void)keyChanged:(UITextField *)field {
    NSString *clean = field.text ?: @"";
    clean = [clean uppercaseString];
    NSString *raw = [[clean componentsSeparatedByString:@"-"] componentsJoinedByString:@""];
    if (raw.length > 16) raw = [raw substringToIndex:16];
    NSMutableString *formatted = [NSMutableString string];
    [raw enumerateSubstringsInRange:NSMakeRange(0, raw.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *sub, NSRange r, NSRange er) {
        if (formatted.length > 0 && formatted.length % 5 == 4) [formatted appendString:@"-"];
        [formatted appendString:sub];
    }];
    field.text = formatted;
    self.statusLabel.text = formatted.length == 19 ? @"Key lista para verificar" : @"Completa los 16 caracteres de la Key";
    self.statusLabel.textColor = [UIColor colorWithWhite:0.55 alpha:1.0];
}

- (void)inspectClipboardSilently {
    NSString *clip = [UIPasteboard generalPasteboard].string;
    if (!clip.length) return;
    NSString *clean = [[clip stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    NSString *raw = [[clean componentsSeparatedByString:@"-"] componentsJoinedByString:@""];
    if (raw.length == 16) {
        self.keyField.text = clean;
        self.statusLabel.text = @"Key detectada en el portapapeles";
        self.statusLabel.textColor = XFAccent2();
        self.pasteButton.alpha = 0.7;
    }
}

- (void)pasteKey:(id)sender {
    NSString *clip = [UIPasteboard generalPasteboard].string;
    if (!clip.length) {
        self.statusLabel.text = @"No hay ninguna Key copiada";
        self.statusLabel.textColor = [UIColor systemOrangeColor];
        return;
    }
    self.keyField.text = clip;
    [self keyChanged:self.keyField];
    self.statusLabel.text = @"Key pegada. Lista para verificar.";
    self.statusLabel.textColor = XFAccent2();
}

- (void)verifyKey:(id)sender {
    NSString *key = [self.keyField.text ?: @"" stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *raw = [[key componentsSeparatedByString:@"-"] componentsJoinedByString:@""];
    if (raw.length != 16) {
        self.statusLabel.text = @"Key inválida o incompleta.";
        self.statusLabel.textColor = [UIColor systemRedColor];
        return;
    }

    self.continueButton.enabled = NO;
    self.pasteButton.enabled = NO;
    self.spinner.hidden = NO;
    [self.spinner startAnimating];
    self.statusLabel.text = @"Verificando Key…";
    self.statusLabel.textColor = XFAccent2();

    // Punto de integración para la validación multiusuario del servidor.
    // En la siguiente etapa esta función debe consultar el backend XITFORGE
    // y permitir la entrada solo cuando el servidor responda con una licencia válida.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.45 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.spinner stopAnimating];
        self.spinner.hidden = YES;
        self.continueButton.enabled = YES;
        self.pasteButton.enabled = YES;

        // Prueba visual: una Key con el formato correcto continúa al motor.
        self.statusLabel.text = @"Key aceptada. Entrando a XITFORGE…";
        self.statusLabel.textColor = [UIColor systemGreenColor];
        [self performSelector:@selector(openMainApp) withObject:nil afterDelay:0.35];
    });
}

- (void)openMainApp {
    ViewController *main = [[ViewController alloc] init];
    [self.navigationController setViewControllers:@[main] animated:YES];
}

@end
