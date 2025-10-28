class AppStrings {
  static const String loading = 'Loading...';
  static const String noInternet = 'No Internet Connection';
  static const String pleaseCheckNetwork =
      'Please check your network connection';

  // Firebase Auth Error Messages
  static const String noUserFound = 'No user found with this email.';
  static const String incorrectPassword = 'Incorrect password.';
  static const String emailFormatInvalid = 'Email format is invalid.';
  static const String userDisabled = 'This user account has been disabled.';
  static const String emailAlreadyInUse = 'This email is already in use.';
  static const String passwordTooWeak = 'Password is too weak.';
  static const String operationNotAllowed =
      'Operation not allowed. Please contact support.';
  static const String tooManyRequests = 'Too many attempts. Try again later.';
  static const String unexpectedError = 'An unexpected error occurred.';

  // Authentication UI Text
  static const String welcomeBack = 'Welcome Back!';
  static const String signInToAccount =
      'Sign in to your account to continue managing your tasks';
  static const String createAccount = 'Create Account';
  static const String signUpDescription =
      'Sign up to create your account and begin organizing your tasks efficiently';
  static const String alreadyHaveAccount = 'Already have an account?';
  static const String dontHaveAccount = 'Don\'t have an account?';
  static const String signIn = 'Sign In';
  static const String signUp = 'Sign Up';
  static const String createAccountButton = 'Create Account';

  // Form Fields
  static const String email = 'Email Address';
  static const String password = 'Password';
  static const String fullName = 'Full Name';
  static const String userName = 'Username';
  static const String confirmPassword = 'Confirm Password';

  // Form Hints
  static const String enterEmail = 'Enter your email';
  static const String enterPassword = 'Enter your password';
  static const String enterFullName = 'Enter your full name';
  static const String chooseUsername = 'Choose a username';
  static const String createPassword = 'Create a password';
  static const String confirmPasswordHint = 'Confirm your password';

  // Validation Messages
  static const String pleaseEnterEmail = 'Please enter your email';
  static const String pleaseEnterValidEmail = 'Please enter a valid email';
  static const String pleaseEnterPassword = 'Please enter your password';
  static const String passwordMinLength =
      'Password must be at least 6 characters';
  static const String pleaseEnterFullName = 'Please enter your full name';
  static const String nameMinLength = 'Name must be at least 2 characters';
  static const String pleaseEnterUsername = 'Please enter a username';
  static const String usernameMinLength =
      'Username must be at least 3 characters';
  static const String pleaseConfirmPassword = 'Please confirm your password';
  static const String passwordsDoNotMatch = 'Passwords do not match';
  static const String pleaseAgreeTerms =
      'Please agree to the terms and conditions';

  // Success Messages
  static const String welcomeBackMessage = 'Welcome back!';
  static const String accountCreatedSuccessfully =
      'Account created successfully!';

  // Error Messages
  static const String invalidCredentials =
      'Invalid credentials. Please try again.';
  static const String failedToCreateAccount =
      'Failed to create account. Please try again.';
  static const String noAccountFound =
      'No account found with this email address';
  static const String incorrectPasswordMessage =
      'Incorrect password. Please try again';
  static const String accountDisabled = 'This account has been disabled';
  static const String tooManyFailedAttempts =
      'Too many failed attempts. Please try again later';
  static const String networkError =
      'Network error. Please check your connection';
  static const String unexpectedErrorMessage =
      'An unexpected error occurred. Please try again';
  static const String emailAlreadyExists =
      'An account with this email already exists';
  static const String passwordTooWeakMessage =
      'Password is too weak. Please choose a stronger password';

  // Terms and Conditions
  static const String iAgreeToThe = 'I agree to the ';
  static const String termsOfService = 'Terms of Service';
  static const String and = ' and ';
  static const String privacyPolicy = 'Privacy Policy';

  // Sync Result
  static const String syncFailed = 'Sync failed';
  static const String allTasksAreAlreadySynced = 'All tasks are already synced';
  static const String syncCompleted = 'Sync completed';
  static const String syncCompletedWithConflicts =
      'Sync completed with conflicts';
  static const String uploaded = 'uploaded';
  static const String downloaded = 'downloaded';
  static const String deleted = 'deleted';

  // Conflict Resolution
  static const String conflictDetected = 'Conflict detected';
  static const String thisTaskHasBeenModifiedBothLocallyAndOnTheServer =
      'This task has been modified both locally and on the server.';
  static const String conflictType = 'Conflict type';
  static const String howWouldYouLikeToResolveThisConflict =
      'How would you like to resolve this conflict?';
  static const String keepLocal = 'Keep local';
  static const String keepRemote = 'Keep cloud';
  static const String merge = 'Merge';

  // Sync Status Indicator
  static const String syncing = 'Syncing...';
  static const String synced = 'Synced';
  static const String online = 'Online';
  static const String offline = 'Offline';
  static const String minutesAgo = 'm ago';
  static const String hoursAgo = 'h ago';
  static const String daysAgo = 'd ago';
  static const String justNow = 'just now';
  static const String today = 'Today';
  static const String tomorrow = 'Tomorrow';
  static const String yesterday = 'Yesterday';
  static const String attachment = 'Attachment';

  // Database Access Denied
  static const String databaseAccessDenied =
      'Database access denied. Please contact support.';

  // Username Already In Use
  static const String usernameAlreadyInUse =
      'This username is already taken. Please choose another one.';
}
