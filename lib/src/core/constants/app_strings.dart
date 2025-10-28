class AppStrings {
  static const String user = 'User';
  static const String loading = 'Loading...';
  static const String noInternet = 'No Internet Connection';
  static const String pleaseCheckNetwork =
      'Please check your network connection';
  static const String noEmail = 'No email';
  static const String noUserData = 'No user data';
  static const String editProfile = 'Edit Profile';
  static const String userInfo = 'User Info';
  static const String updateYourPersonalInformation = 'Update your personal information';
  static const String displayName = 'Display Name';
  static const String enterYourDisplayName = 'Enter your display name';
  static const String yourEmailAddress = 'Your email address';
  static const String saveChanges = 'Save Changes';
  static const String profileUpdatedSuccessfully = 'Profile updated successfully';

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

  // Task Management
  static const String tasks = 'Tasks';
  static const String addTask = 'Add Task';
  static const String editTask = 'Edit Task';
  static const String createNewTask = 'Create New Task';
  static const String updateYourTaskDetails = 'Update your task details';
  static const String addDetailsToOrganizeYourWork =
      'Add details to organize your work';
  static const String taskTitle = 'Task Title';
  static const String taskDescription = 'Description';
  static const String dueDate = 'Due Date';
  static const String selectDate = 'Select Date';
  static const String selectDueDate = 'Select when this task is due';
  static const String enterTaskTitle = 'What needs to be done?';
  static const String enterTaskDescription =
      'Add more details about this task...';
  static const String pleaseEnterTaskTitle = 'Task title is required';
  static const String requiredFieldsMissing = 'Required Fields Missing';
  static const String optional = 'Optional';
  static const String attachments = 'Attachments';
  static const String save = 'Save';
  static const String update = 'Update';
  static const String saving = 'Saving...';
  static const String updating = 'Updating...';
  static const String taskCreatedSuccessfully = 'Task created successfully';
  static const String taskUpdatedSuccessfully = 'Task updated successfully';
  static const String taskDeletedSuccessfully = 'Task deleted successfully';
  static const String failedToCreateTask = 'Failed to create task';
  static const String failedToUpdateTask = 'Failed to update task';
  static const String failedToDeleteTask = 'Failed to delete task';
  static const String noTasksYet = 'No tasks yet';
  static const String createYourFirstTask =
      'Create your first task to get started';
  static const String allTasks = 'All Tasks';
  static const String myTasks = 'My Tasks';
  static const String syncTasks = 'Sync Tasks';
  static const String deleteTask = 'Delete Task';
  static const String areYouSureDeleteTask = 'Are you sure you want to delete';
  static const String actionCannotBeUndone = 'This action cannot be undone';
  static const String delete = 'Delete';
  static const String pending = 'Pending';
  static const String completed = 'Completed';
  static const String overdue = 'Overdue';
  static const String filter = 'Filter';
  static const String clear = 'Clear';
  static const String search = 'Search';
  static const String searchTasks = 'Search tasks...';
  static const String noResultsFound = 'No results found';
  static const String tryDifferentKeywords = 'Try different keywords';
  static const String retry = 'Retry';
  static const String cancel = 'Cancel';
  static const String close = 'Close';
  static const String back = 'Back';
  static const String next = 'Next';
  static const String done = 'Done';
  static const String ok = 'OK';
  static const String yes = 'Yes';
  static const String no = 'No';

  // Conflict Resolution
  static const String resolveConflicts = 'Resolve Conflicts';
  static const String syncConflictDetected = 'Sync Conflict Detected';
  static const String thisTaskWasModifiedOnBothDevices =
      'This task was modified on both devices. Choose which version to keep.';
  static const String conflictDetails = 'Conflict Details';
  static const String taskId = 'Task ID';
  static const String detectedAt = 'Detected At';
  static const String versionComparison = 'Version Comparison';
  static const String localVersion = 'Local Version';
  static const String cloudVersion = 'Cloud Version';
  static const String chooseResolution = 'Choose Resolution';
  static const String keepLocalVersion = 'Keep Local Version';
  static const String keepCloudVersion = 'Keep Cloud Version';
  static const String useTheVersionFromThisDevice =
      'Use the version from this device';
  static const String useTheVersionFromTheServer =
      'Use the version from the server';
  static const String theSelectedVersionWillBeSavedAndSynced =
      'The selected version will be saved and synced across all your devices.';
  static const String resolveConflict = 'Resolve Conflict';
  static const String bothVersionsModified = 'Both versions modified';
  static const String localDeletedCloudModified =
      'Local deleted, cloud modified';
  static const String cloudDeletedLocalModified =
      'Cloud deleted, local modified';
  static const String bothVersionsDeleted = 'Both versions deleted';
  static const String updated = 'Updated';
  static const String attachmentRemovedSuccessfully =
      'Attachment removed successfully';
  static const String failedToRemoveAttachment = 'Failed to remove attachment';
  static const String pickImage = 'Pick Image';
  static const String pickFile = 'Pick File';
  static const String tapToViewFullScreen = 'Tap to view full screen';
  static const String tapToOpenFile = 'Tap to open file';
  static const String failedToOpenFile = 'Failed to open file';
  static const String noAttachment = 'No attachment';
  static const String removeAttachment = 'Remove attachment';

  // Profile
  static const String profile = 'Profile';
  static const String settings = 'Settings';
  static const String logout = 'Logout';
  static const String about = 'About';
  static const String version = 'Version';
  static const String buildNumber = 'Build Number';

  // Drawer
  static const String home = 'Home';
  static const String completedTasks = 'Completed Tasks';
  static const String pendingTasks = 'Pending Tasks';
  static const String overdueTasks = 'Overdue Tasks';

  // Error Messages
  static const String somethingWentWrong = 'Something went wrong';
  static const String pleaseTryAgain = 'Please try again';
  static const String connectionTimeout = 'Connection timeout';
  static const String serverError = 'Server error';
  static const String unknownError = 'Unknown error occurred';

  // Success Messages
  static const String operationCompletedSuccessfully =
      'Operation completed successfully';
  static const String changesSaved = 'Changes saved';
  static const String dataSynced = 'Data synced';

  // Loading States
  static const String loadingData = 'Loading data...';
  static const String processing = 'Processing...';
  static const String pleaseWait = 'Please wait...';

  // Empty States
  static const String noDataAvailable = 'No data available';
  static const String nothingToShow = 'Nothing to show';
  static const String emptyList = 'List is empty';

  // Date/Time
  static const String thisWeek = 'This Week';
  static const String lastWeek = 'Last Week';
  static const String thisMonth = 'This Month';
  static const String lastMonth = 'Last Month';

  // File Types
  static const String image = 'Image';
  static const String document = 'Document';
  static const String pdf = 'PDF';
  static const String video = 'Video';
  static const String audio = 'Audio';
  static const String archive = 'Archive';
  static const String other = 'Other';

  // Conflict Resolution Additional
  static const String noConflictsFound = 'No Conflicts Found';
  static const String allYourTasksAreInSync = 'All your tasks are in sync!';
  static const String continueText = 'Continue';
  static const String resolvingConflicts = 'Resolving Conflicts';
  static const String pleaseWaitWhileWeResolveConflicts =
      'Please wait while we resolve conflicts...';
  static const String conflictResolvedSuccessfully =
      'Conflict resolved successfully';
  static const String failedToResolveConflict = 'Failed to resolve conflict';
  static const String allConflictsResolved = 'All conflicts resolved';
  static const String returningToTasks = 'Returning to tasks...';
  static const String reviewAndResolveEachConflict =
      'Review and resolve each conflict in the dialog.';
  static const String currentConflict = 'Current conflict';
  static const String resolveThisConflict = 'Resolve This Conflict';
  static const String of = 'of';
  static const String conflictsResolved = 'Conflicts Resolved';
  static const String allConflictsHaveBeenSuccessfullyResolved =
      'All conflicts have been successfully resolved. Your tasks are now in sync.';

  // User Profile
  static const String failedToUpdateProfile = 'Failed to update profile';

  // Task Management
  static const String failedToLoadTasks = 'Failed to load tasks';
  static const String failedToLoadTask = 'Failed to load task';
  static const String failedToToggleTaskStatus = 'Failed to toggle task status';
  static const String failedToSyncTasks = 'Failed to sync tasks';
  static const String failedToCompleteConflictResolution =
      'Failed to complete conflict resolution';
  static const String titleIsRequired = 'Title is required';
  static const String titleMustBeAtLeast3CharactersLong =
      'Title must be at least 3 characters long';
  static const String titleMustBeLessThan100Characters =
      'Title must be less than 100 characters';
  static const String descriptionMustBeLessThan500Characters =
      'Description must be less than 500 characters';
  static const String dueDateIsRequired = 'Due date is required';
  static const String dueDateCannotBeInThePast =
      'Due date cannot be in the past';
  static const String dueDateCannotBeMoreThan1YearInTheFuture =
      'Due date cannot be more than 1 year in the future';

  // Date/Time
  static const String january = 'January';
  static const String february = 'February';
  static const String march = 'March';
  static const String april = 'April';
  static const String may = 'May';
  static const String june = 'June';
  static const String july = 'July';
  static const String august = 'August';
  static const String september = 'September';
  static const String october = 'October';
  static const String november = 'November';
  static const String december = 'December';

  // Task Detail Page
  static const String theTaskYouAreLookingForDoesNotExist =
      'The task you\'re looking for doesn\'t exist';
  static const String loadingTaskDetails = 'Loading task details...';
}
