///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsEn = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations
	late final Translations$dialogs$en dialogs = Translations$dialogs$en.internal(_root);
	late final Translations$formErr$en formErr = Translations$formErr$en.internal(_root);

	/// en: 'Retry'
	String get retry => 'Retry';

	late final Translations$errorState$en errorState = Translations$errorState$en.internal(_root);
	late final Translations$nav$en nav = Translations$nav$en.internal(_root);
	late final Translations$unread$en unread = Translations$unread$en.internal(_root);
	late final Translations$search$en search = Translations$search$en.internal(_root);
	late final Translations$share$en share = Translations$share$en.internal(_root);
	late final Translations$settings$en settings = Translations$settings$en.internal(_root);
	late final Translations$apiError$en apiError = Translations$apiError$en.internal(_root);
	late final Translations$login$en login = Translations$login$en.internal(_root);
	late final Translations$edit$en edit = Translations$edit$en.internal(_root);
	late final Translations$tagEdit$en tagEdit = Translations$tagEdit$en.internal(_root);
	late final Translations$tagNew$en tagNew = Translations$tagNew$en.internal(_root);
	late final Translations$tags$en tags = Translations$tags$en.internal(_root);
	late final Translations$editBar$en editBar = Translations$editBar$en.internal(_root);
	late final Translations$filter$en filter = Translations$filter$en.internal(_root);
	late final Translations$colorPicker$en colorPicker = Translations$colorPicker$en.internal(_root);
	late final Translations$unauthRedirect$en unauthRedirect = Translations$unauthRedirect$en.internal(_root);
	Map<String, String> get linkAction => {
		'archive': 'Archive',
		'unarchive': 'Unarchive',
		'favorite': 'Favorite',
		'unfavorite': 'Unfavorite',
		'select': 'Select',
		'edit': 'Edit',
		'editTags': 'Edit Tags',
		'share': 'Share',
		'delete': 'Delete',
	};
}

// Path: dialogs
class Translations$dialogs$en {
	Translations$dialogs$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'Delete'
	String get delete => 'Delete';

	/// en: 'Close'
	String get close => 'Close';

	/// en: 'Confirm'
	String get confirm => 'Confirm';

	/// en: 'Copied to clipboard'
	String get copiedToClipboard => 'Copied to clipboard';

	/// en: 'Loading...'
	String get loading => 'Loading...';
}

// Path: formErr
class Translations$formErr$en {
	Translations$formErr$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'This field cannot be empty.'
	String get emptyValue => 'This field cannot be empty.';

	/// en: 'Please enter a valid URL.'
	String get invalidUrl => 'Please enter a valid URL.';
}

// Path: errorState
class Translations$errorState$en {
	Translations$errorState$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Details'
	String get details => 'Details';

	/// en: 'Error details'
	String get errorDetails => 'Error details';
}

// Path: nav
class Translations$nav$en {
	Translations$nav$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Unread'
	String get unread => 'Unread';

	/// en: 'Search'
	String get search => 'Search';

	/// en: 'Settings'
	String get settings => 'Settings';
}

// Path: unread
class Translations$unread$en {
	Translations$unread$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Unread (${count: compact})'
	String title({required num count}) => 'Unread (${NumberFormat.compact(locale: 'en').format(count)})';

	/// en: 'Toggle sort order (currently oldest first)'
	String get toggleSortingAsc => 'Toggle sort order (currently oldest first)';

	/// en: 'Toggle sort order (currently newest first)'
	String get toggleSortingDesc => 'Toggle sort order (currently newest first)';
}

// Path: search
class Translations$search$en {
	Translations$search$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Search'
	String get search => 'Search';

	/// en: 'Filter'
	String get filterTooltip => 'Filter';
}

// Path: share
class Translations$share$en {
	Translations$share$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Add Link'
	String get title => 'Add Link';

	/// en: 'Link added'
	String get success => 'Link added';
}

// Path: settings
class Translations$settings$en {
	Translations$settings$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Settings'
	String get title => 'Settings';

	/// en: 'Preferences'
	String get preferences => 'Preferences';

	/// en: 'Tag Management'
	String get tag => 'Tag Management';

	/// en: 'About'
	String get about => 'About';

	/// en: 'Help & Support'
	String get helpSupport => 'Help & Support';

	/// en: 'App Version'
	String get appVersion => 'App Version';

	late final Translations$settings$theme$en theme = Translations$settings$theme$en.internal(_root);
	late final Translations$settings$logout$en logout = Translations$settings$logout$en.internal(_root);

	/// en: 'Copy API URL to Clipboard'
	String get copyApiUrl => 'Copy API URL to Clipboard';

	/// en: '@${login} (${source}) on ${host}'
	String userLine({required Object login, required Object source, required Object host}) => '@${login} (${source}) on ${host}';

	/// en: 'Not authenticated'
	String get unauthenticated => 'Not authenticated';
}

// Path: apiError
class Translations$apiError$en {
	Translations$apiError$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Network error. Please check your connection.'
	String get network => 'Network error. Please check your connection.';

	/// en: 'Request was cancelled.'
	String get cancelled => 'Request was cancelled.';

	/// en: '$message'
	String serverError({required Object message}) => '${message}';

	/// en: 'Unexpected server response.'
	String get invalidResponse => 'Unexpected server response.';

	/// en: 'An unexpected error occurred.'
	String get unknown => 'An unexpected error occurred.';
}

// Path: login
class Translations$login$en {
	Translations$login$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Login'
	String get title => 'Login';

	/// en: 'Haudoi is a bookmark management app that helps you save, organize, and access your links across all your devices.'
	String get description => 'Haudoi is a bookmark management app that helps you save, organize, and access your links across all your devices.';

	/// en: 'Enter the API URL of your self-hosted Haudoi server. If you don't have one, see the GitHub repository below for setup instructions.'
	String get apiUrlInstructions => 'Enter the API URL of your self-hosted Haudoi server. If you don\'t have one, see the GitHub repository below for setup instructions.';

	/// en: 'API URL'
	String get apiUrlLabel => 'API URL';

	/// en: 'https://your-haudoi-server.com'
	String get apiUrlHint => 'https://your-haudoi-server.com';

	/// en: 'Login'
	String get loginButton => 'Login';

	/// en: 'View on GitHub'
	String get viewOnGithub => 'View on GitHub';

	/// en: 'Login Provider'
	String get loginProvider => 'Login Provider';

	/// en: 'GitHub'
	String get providerGithub => 'GitHub';

	/// en: 'Google'
	String get providerGoogle => 'Google';

	/// en: 'Authentication failed: No token received'
	String get authFailedNoToken => 'Authentication failed: No token received';

	/// en: 'Authentication failed: $error'
	String authFailedMessage({required Object error}) => 'Authentication failed: ${error}';

	/// en: 'Cannot reach server. Is the URL correct?'
	String get serverUnreachable => 'Cannot reach server. Is the URL correct?';

	/// en: 'URL does not appear to point to a valid Haudoi server.'
	String get serverInvalidResponse => 'URL does not appear to point to a valid Haudoi server.';

	/// en: 'Server error: $message'
	String serverError({required Object message}) => 'Server error: ${message}';
}

// Path: edit
class Translations$edit$en {
	Translations$edit$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Save'
	String get save => 'Save';

	/// en: 'Changes saved'
	String get toast => 'Changes saved';

	/// en: 'Edit Link'
	String get title => 'Edit Link';

	late final Translations$edit$fields$en fields = Translations$edit$fields$en.internal(_root);
	late final Translations$edit$tags$en tags = Translations$edit$tags$en.internal(_root);
}

// Path: tagEdit
class Translations$tagEdit$en {
	Translations$tagEdit$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Edit Tag'
	String get title => 'Edit Tag';

	/// en: 'Preview'
	String get preview => 'Preview';

	/// en: 'Failed to load tags: $error'
	String loadingError({required Object error}) => 'Failed to load tags: ${error}';

	/// en: 'Tag $id not found'
	String notFound({required Object id}) => 'Tag ${id} not found';

	late final Translations$tagEdit$fields$en fields = Translations$tagEdit$fields$en.internal(_root);
	late final Translations$tagEdit$discard$en discard = Translations$tagEdit$discard$en.internal(_root);
	late final Translations$tagEdit$toast$en toast = Translations$tagEdit$toast$en.internal(_root);
}

// Path: tagNew
class Translations$tagNew$en {
	Translations$tagNew$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'New Tag'
	String get title => 'New Tag';

	/// en: 'Create'
	String get create => 'Create';

	/// en: 'New Tag'
	String get defaultName => 'New Tag';

	/// en: 'Your unsaved tag draft will be lost.'
	String get discardMessage => 'Your unsaved tag draft will be lost.';

	late final Translations$tagNew$toast$en toast = Translations$tagNew$toast$en.internal(_root);
}

// Path: tags
class Translations$tags$en {
	Translations$tags$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Tags'
	String get title => 'Tags';

	/// en: 'Create Tag'
	String get createTag => 'Create Tag';

	late final Translations$tags$empty$en empty = Translations$tags$empty$en.internal(_root);

	/// en: 'Edit tag'
	String get editTooltip => 'Edit tag';

	/// en: 'Delete tag'
	String get deleteTooltip => 'Delete tag';

	late final Translations$tags$deleteDialog$en deleteDialog = Translations$tags$deleteDialog$en.internal(_root);

	/// en: 'Created ${date}'
	String createdLabel({required Object date}) => 'Created ${date}';

	late final Translations$tags$toast$en toast = Translations$tags$toast$en.internal(_root);
}

// Path: editBar
class Translations$editBar$en {
	Translations$editBar$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: '$count items'
	String title({required Object count}) => '${count} items';

	/// en: 'Cancel selection'
	String get cancel => 'Cancel selection';

	/// en: 'More actions'
	String get more => 'More actions';

	/// en: 'Delete $count links permanently?'
	String deletePrompt({required Object count}) => 'Delete ${count} links permanently?';

	/// en: 'This is permanent and cannot be undone.'
	String get deleteWarning => 'This is permanent and cannot be undone.';
}

// Path: filter
class Translations$filter$en {
	Translations$filter$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Search Query (DSL) documentation'
	String get dsl_doc => 'Search Query (DSL) documentation';

	/// en: 'Common Queries'
	String get common_query => 'Common Queries';

	late final Translations$filter$queries$en queries = Translations$filter$queries$en.internal(_root);
	late final Translations$filter$order$en order = Translations$filter$order$en.internal(_root);
}

// Path: colorPicker
class Translations$colorPicker$en {
	Translations$colorPicker$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Color'
	String get label => 'Color';

	/// en: 'Pick color'
	String get pickColor => 'Pick color';

	/// en: 'Preset colors'
	String get presetColors => 'Preset colors';

	/// en: 'Randomize'
	String get randomize => 'Randomize';

	/// en: 'Preset'
	String get preset => 'Preset';

	/// en: 'Custom'
	String get custom => 'Custom';
}

// Path: unauthRedirect
class Translations$unauthRedirect$en {
	Translations$unauthRedirect$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Logout'
	String get logout => 'Logout';

	/// en: 'Network error. Log out and reconfigure?'
	String get networkErr => 'Network error. Log out and reconfigure?';
}

// Path: settings.theme
class Translations$settings$theme$en {
	Translations$settings$theme$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Theme'
	String get title => 'Theme';

	/// en: 'Select Theme'
	String get select => 'Select Theme';

	/// en: 'Light'
	String get light => 'Light';

	/// en: 'Dark'
	String get dark => 'Dark';

	/// en: 'System Default'
	String get system => 'System Default';
}

// Path: settings.logout
class Translations$settings$logout$en {
	Translations$settings$logout$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Logout'
	String get title => 'Logout';

	/// en: 'Confirm Logout'
	String get confirmDialog => 'Confirm Logout';

	/// en: 'Are you sure you want to logout?'
	String get confirmText => 'Are you sure you want to logout?';
}

// Path: edit.fields
class Translations$edit$fields$en {
	Translations$edit$fields$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Title'
	String get title => 'Title';

	/// en: 'URL'
	String get url => 'URL';

	/// en: 'Note'
	String get note => 'Note';

	/// en: 'Favorite'
	String get favorite => 'Favorite';

	/// en: 'Archive'
	String get archive => 'Archive';
}

// Path: edit.tags
class Translations$edit$tags$en {
	Translations$edit$tags$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Edit Tags'
	String get title => 'Edit Tags';

	late final Translations$edit$tags$empty$en empty = Translations$edit$tags$empty$en.internal(_root);
}

// Path: tagEdit.fields
class Translations$tagEdit$fields$en {
	Translations$tagEdit$fields$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Title'
	String get title => 'Title';

	/// en: 'Emoji'
	String get emoji => 'Emoji';

	/// en: 'e.g. 🔖'
	String get emojiHint => 'e.g. 🔖';
}

// Path: tagEdit.discard
class Translations$tagEdit$discard$en {
	Translations$tagEdit$discard$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Discard changes?'
	String get title => 'Discard changes?';

	/// en: 'Your unsaved changes will be lost.'
	String get message => 'Your unsaved changes will be lost.';

	/// en: 'Stay'
	String get stay => 'Stay';

	/// en: 'Discard'
	String get discard => 'Discard';
}

// Path: tagEdit.toast
class Translations$tagEdit$toast$en {
	Translations$tagEdit$toast$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Tag updated'
	String get updated => 'Tag updated';

	/// en: 'Failed to update tag: $error'
	String updateFailed({required Object error}) => 'Failed to update tag: ${error}';
}

// Path: tagNew.toast
class Translations$tagNew$toast$en {
	Translations$tagNew$toast$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Tag created'
	String get created => 'Tag created';

	/// en: 'Failed to create tag: $error'
	String createFailed({required Object error}) => 'Failed to create tag: ${error}';
}

// Path: tags.empty
class Translations$tags$empty$en {
	Translations$tags$empty$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'No tags yet'
	String get message => 'No tags yet';

	/// en: 'Create Tag'
	String get button => 'Create Tag';
}

// Path: tags.deleteDialog
class Translations$tags$deleteDialog$en {
	Translations$tags$deleteDialog$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Delete Tag'
	String get title => 'Delete Tag';

	/// en: 'Are you sure you want to delete "${name}"?'
	String deleteMessage({required Object name}) => 'Are you sure you want to delete "${name}"?';

	/// en: 'Links with this tag will remain unchanged.'
	String get warning => 'Links with this tag will remain unchanged.';
}

// Path: tags.toast
class Translations$tags$toast$en {
	Translations$tags$toast$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Tag deleted'
	String get deleted => 'Tag deleted';

	/// en: 'Failed to delete tag: $error'
	String deleteFailed({required Object error}) => 'Failed to delete tag: ${error}';
}

// Path: filter.queries
class Translations$filter$queries$en {
	Translations$filter$queries$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'All Links'
	String get all => 'All Links';

	/// en: 'Archived'
	String get archived => 'Archived';

	/// en: 'Not Archived'
	String get unarchived => 'Not Archived';

	/// en: 'Favorite'
	String get favorite => 'Favorite';

	/// en: 'Not Favorite'
	String get unfavorite => 'Not Favorite';
}

// Path: filter.order
class Translations$filter$order$en {
	Translations$filter$order$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Order'
	String get title => 'Order';

	/// en: 'Newest First'
	String get newestFirst => 'Newest First';

	/// en: 'Oldest First'
	String get oldestFirst => 'Oldest First';
}

// Path: edit.tags.empty
class Translations$edit$tags$empty$en {
	Translations$edit$tags$empty$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'No tags available. Create tags to organize your links.'
	String get message => 'No tags available. Create tags to organize your links.';

	/// en: 'Create Tag'
	String get button => 'Create Tag';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'dialogs.cancel' => 'Cancel',
			'dialogs.delete' => 'Delete',
			'dialogs.close' => 'Close',
			'dialogs.confirm' => 'Confirm',
			'dialogs.copiedToClipboard' => 'Copied to clipboard',
			'dialogs.loading' => 'Loading...',
			'formErr.emptyValue' => 'This field cannot be empty.',
			'formErr.invalidUrl' => 'Please enter a valid URL.',
			'retry' => 'Retry',
			'errorState.details' => 'Details',
			'errorState.errorDetails' => 'Error details',
			'nav.unread' => 'Unread',
			'nav.search' => 'Search',
			'nav.settings' => 'Settings',
			'unread.title' => ({required num count}) => 'Unread (${NumberFormat.compact(locale: 'en').format(count)})',
			'unread.toggleSortingAsc' => 'Toggle sort order (currently oldest first)',
			'unread.toggleSortingDesc' => 'Toggle sort order (currently newest first)',
			'search.search' => 'Search',
			'search.filterTooltip' => 'Filter',
			'share.title' => 'Add Link',
			'share.success' => 'Link added',
			'settings.title' => 'Settings',
			'settings.preferences' => 'Preferences',
			'settings.tag' => 'Tag Management',
			'settings.about' => 'About',
			'settings.helpSupport' => 'Help & Support',
			'settings.appVersion' => 'App Version',
			'settings.theme.title' => 'Theme',
			'settings.theme.select' => 'Select Theme',
			'settings.theme.light' => 'Light',
			'settings.theme.dark' => 'Dark',
			'settings.theme.system' => 'System Default',
			'settings.logout.title' => 'Logout',
			'settings.logout.confirmDialog' => 'Confirm Logout',
			'settings.logout.confirmText' => 'Are you sure you want to logout?',
			'settings.copyApiUrl' => 'Copy API URL to Clipboard',
			'settings.userLine' => ({required Object login, required Object source, required Object host}) => '@${login} (${source}) on ${host}',
			'settings.unauthenticated' => 'Not authenticated',
			'apiError.network' => 'Network error. Please check your connection.',
			'apiError.cancelled' => 'Request was cancelled.',
			'apiError.serverError' => ({required Object message}) => '${message}',
			'apiError.invalidResponse' => 'Unexpected server response.',
			'apiError.unknown' => 'An unexpected error occurred.',
			'login.title' => 'Login',
			'login.description' => 'Haudoi is a bookmark management app that helps you save, organize, and access your links across all your devices.',
			'login.apiUrlInstructions' => 'Enter the API URL of your self-hosted Haudoi server. If you don\'t have one, see the GitHub repository below for setup instructions.',
			'login.apiUrlLabel' => 'API URL',
			'login.apiUrlHint' => 'https://your-haudoi-server.com',
			'login.loginButton' => 'Login',
			'login.viewOnGithub' => 'View on GitHub',
			'login.loginProvider' => 'Login Provider',
			'login.providerGithub' => 'GitHub',
			'login.providerGoogle' => 'Google',
			'login.authFailedNoToken' => 'Authentication failed: No token received',
			'login.authFailedMessage' => ({required Object error}) => 'Authentication failed: ${error}',
			'login.serverUnreachable' => 'Cannot reach server. Is the URL correct?',
			'login.serverInvalidResponse' => 'URL does not appear to point to a valid Haudoi server.',
			'login.serverError' => ({required Object message}) => 'Server error: ${message}',
			'edit.save' => 'Save',
			'edit.toast' => 'Changes saved',
			'edit.title' => 'Edit Link',
			'edit.fields.title' => 'Title',
			'edit.fields.url' => 'URL',
			'edit.fields.note' => 'Note',
			'edit.fields.favorite' => 'Favorite',
			'edit.fields.archive' => 'Archive',
			'edit.tags.title' => 'Edit Tags',
			'edit.tags.empty.message' => 'No tags available. Create tags to organize your links.',
			'edit.tags.empty.button' => 'Create Tag',
			'tagEdit.title' => 'Edit Tag',
			'tagEdit.preview' => 'Preview',
			'tagEdit.loadingError' => ({required Object error}) => 'Failed to load tags: ${error}',
			'tagEdit.notFound' => ({required Object id}) => 'Tag ${id} not found',
			'tagEdit.fields.title' => 'Title',
			'tagEdit.fields.emoji' => 'Emoji',
			'tagEdit.fields.emojiHint' => 'e.g. 🔖',
			'tagEdit.discard.title' => 'Discard changes?',
			'tagEdit.discard.message' => 'Your unsaved changes will be lost.',
			'tagEdit.discard.stay' => 'Stay',
			'tagEdit.discard.discard' => 'Discard',
			'tagEdit.toast.updated' => 'Tag updated',
			'tagEdit.toast.updateFailed' => ({required Object error}) => 'Failed to update tag: ${error}',
			'tagNew.title' => 'New Tag',
			'tagNew.create' => 'Create',
			'tagNew.defaultName' => 'New Tag',
			'tagNew.discardMessage' => 'Your unsaved tag draft will be lost.',
			'tagNew.toast.created' => 'Tag created',
			'tagNew.toast.createFailed' => ({required Object error}) => 'Failed to create tag: ${error}',
			'tags.title' => 'Tags',
			'tags.createTag' => 'Create Tag',
			'tags.empty.message' => 'No tags yet',
			'tags.empty.button' => 'Create Tag',
			'tags.editTooltip' => 'Edit tag',
			'tags.deleteTooltip' => 'Delete tag',
			'tags.deleteDialog.title' => 'Delete Tag',
			'tags.deleteDialog.deleteMessage' => ({required Object name}) => 'Are you sure you want to delete "${name}"?',
			'tags.deleteDialog.warning' => 'Links with this tag will remain unchanged.',
			'tags.createdLabel' => ({required Object date}) => 'Created ${date}',
			'tags.toast.deleted' => 'Tag deleted',
			'tags.toast.deleteFailed' => ({required Object error}) => 'Failed to delete tag: ${error}',
			'editBar.title' => ({required Object count}) => '${count} items',
			'editBar.cancel' => 'Cancel selection',
			'editBar.more' => 'More actions',
			'editBar.deletePrompt' => ({required Object count}) => 'Delete ${count} links permanently?',
			'editBar.deleteWarning' => 'This is permanent and cannot be undone.',
			'filter.dsl_doc' => 'Search Query (DSL) documentation',
			'filter.common_query' => 'Common Queries',
			'filter.queries.all' => 'All Links',
			'filter.queries.archived' => 'Archived',
			'filter.queries.unarchived' => 'Not Archived',
			'filter.queries.favorite' => 'Favorite',
			'filter.queries.unfavorite' => 'Not Favorite',
			'filter.order.title' => 'Order',
			'filter.order.newestFirst' => 'Newest First',
			'filter.order.oldestFirst' => 'Oldest First',
			'colorPicker.label' => 'Color',
			'colorPicker.pickColor' => 'Pick color',
			'colorPicker.presetColors' => 'Preset colors',
			'colorPicker.randomize' => 'Randomize',
			'colorPicker.preset' => 'Preset',
			'colorPicker.custom' => 'Custom',
			'unauthRedirect.logout' => 'Logout',
			'unauthRedirect.networkErr' => 'Network error. Log out and reconfigure?',
			'linkAction.archive' => 'Archive',
			'linkAction.unarchive' => 'Unarchive',
			'linkAction.favorite' => 'Favorite',
			'linkAction.unfavorite' => 'Unfavorite',
			'linkAction.select' => 'Select',
			'linkAction.edit' => 'Edit',
			'linkAction.editTags' => 'Edit Tags',
			'linkAction.share' => 'Share',
			'linkAction.delete' => 'Delete',
			_ => null,
		};
	}
}
