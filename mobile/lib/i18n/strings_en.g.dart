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
	late final TranslationsDialogsEn dialogs = TranslationsDialogsEn.internal(_root);
	late final TranslationsFormErrEn formErr = TranslationsFormErrEn.internal(_root);
	late final TranslationsNavEn nav = TranslationsNavEn.internal(_root);
	late final TranslationsUnreadEn unread = TranslationsUnreadEn.internal(_root);
	late final TranslationsSearchEn search = TranslationsSearchEn.internal(_root);
	late final TranslationsShareEn share = TranslationsShareEn.internal(_root);
	late final TranslationsSettingsEn settings = TranslationsSettingsEn.internal(_root);
	late final TranslationsLoginEn login = TranslationsLoginEn.internal(_root);
	late final TranslationsEditEn edit = TranslationsEditEn.internal(_root);
	late final TranslationsEditBarEn editBar = TranslationsEditBarEn.internal(_root);
	late final TranslationsFilterEn filter = TranslationsFilterEn.internal(_root);
	Map<String, String> get linkAction => {
		'archive': 'Archive',
		'unarchive': 'Unarchive',
		'favorite': 'Favorite',
		'unfavorite': 'Unfavorite',
		'select': 'Select',
		'edit': 'Edit',
		'share': 'Share',
		'delete': 'Delete',
	};
}

// Path: dialogs
class TranslationsDialogsEn {
	TranslationsDialogsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'Delete'
	String get delete => 'Delete';

	/// en: 'Close'
	String get close => 'Close';

	/// en: 'Copied to clipboard'
	String get copiedToClipboard => 'Copied to clipboard';

	/// en: 'Loading...'
	String get loading => 'Loading...';
}

// Path: formErr
class TranslationsFormErrEn {
	TranslationsFormErrEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'This field cannot be empty.'
	String get emptyValue => 'This field cannot be empty.';

	/// en: 'Please enter a valid URL.'
	String get invalidUrl => 'Please enter a valid URL.';
}

// Path: nav
class TranslationsNavEn {
	TranslationsNavEn.internal(this._root);

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
class TranslationsUnreadEn {
	TranslationsUnreadEn.internal(this._root);

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
class TranslationsSearchEn {
	TranslationsSearchEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Search'
	String get search => 'Search';

	/// en: 'Filter'
	String get filterTooltip => 'Filter';
}

// Path: share
class TranslationsShareEn {
	TranslationsShareEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Add Link'
	String get title => 'Add Link';

	/// en: 'Link added'
	String get success => 'Link added';
}

// Path: settings
class TranslationsSettingsEn {
	TranslationsSettingsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Settings'
	String get title => 'Settings';

	/// en: 'Preferences'
	String get preferences => 'Preferences';

	/// en: 'About'
	String get about => 'About';

	/// en: 'Help & Support'
	String get helpSupport => 'Help & Support';

	/// en: 'App Version'
	String get appVersion => 'App Version';

	late final TranslationsSettingsThemeEn theme = TranslationsSettingsThemeEn.internal(_root);
	late final TranslationsSettingsLogoutEn logout = TranslationsSettingsLogoutEn.internal(_root);

	/// en: 'Copy API URL to Clipboard'
	String get copyApiUrl => 'Copy API URL to Clipboard';

	/// en: '@${login} (${source}) on ${host}'
	String userLine({required Object login, required Object source, required Object host}) => '@${login} (${source}) on ${host}';

	/// en: 'Not authenticated'
	String get unauthenticated => 'Not authenticated';
}

// Path: login
class TranslationsLoginEn {
	TranslationsLoginEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Login'
	String get title => 'Login';

	/// en: 'API URL'
	String get apiUrlLabel => 'API URL';

	/// en: 'Login'
	String get loginButton => 'Login';

	/// en: 'Authentication failed: No token received'
	String get authFailedNoToken => 'Authentication failed: No token received';

	/// en: 'Authentication failed: $error'
	String authFailedMessage({required Object error}) => 'Authentication failed: ${error}';
}

// Path: edit
class TranslationsEditEn {
	TranslationsEditEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Save'
	String get save => 'Save';

	/// en: 'Changes saved'
	String get toast => 'Changes saved';

	/// en: 'Retry'
	String get retry => 'Retry';

	/// en: 'Edit Link'
	String get title => 'Edit Link';

	late final TranslationsEditFieldsEn fields = TranslationsEditFieldsEn.internal(_root);
}

// Path: editBar
class TranslationsEditBarEn {
	TranslationsEditBarEn.internal(this._root);

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
class TranslationsFilterEn {
	TranslationsFilterEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsFilterArchiveEn archive = TranslationsFilterArchiveEn.internal(_root);
	late final TranslationsFilterFavoriteEn favorite = TranslationsFilterFavoriteEn.internal(_root);
	late final TranslationsFilterOrderEn order = TranslationsFilterOrderEn.internal(_root);
}

// Path: settings.theme
class TranslationsSettingsThemeEn {
	TranslationsSettingsThemeEn.internal(this._root);

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
class TranslationsSettingsLogoutEn {
	TranslationsSettingsLogoutEn.internal(this._root);

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
class TranslationsEditFieldsEn {
	TranslationsEditFieldsEn.internal(this._root);

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

// Path: filter.archive
class TranslationsFilterArchiveEn {
	TranslationsFilterArchiveEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Archive'
	String get title => 'Archive';

	/// en: 'All'
	String get all => 'All';

	/// en: 'Archived'
	String get oui => 'Archived';

	/// en: 'Not Archived'
	String get non => 'Not Archived';
}

// Path: filter.favorite
class TranslationsFilterFavoriteEn {
	TranslationsFilterFavoriteEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Favorite'
	String get title => 'Favorite';

	/// en: 'All'
	String get all => 'All';

	/// en: 'Favorited'
	String get oui => 'Favorited';

	/// en: 'Not Favorited'
	String get non => 'Not Favorited';
}

// Path: filter.order
class TranslationsFilterOrderEn {
	TranslationsFilterOrderEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Order'
	String get title => 'Order';

	/// en: 'Newest First'
	String get newestFirst => 'Newest First';

	/// en: 'Oldest First'
	String get oldestFirst => 'Oldest First';
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
			'dialogs.copiedToClipboard' => 'Copied to clipboard',
			'dialogs.loading' => 'Loading...',
			'formErr.emptyValue' => 'This field cannot be empty.',
			'formErr.invalidUrl' => 'Please enter a valid URL.',
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
			'login.title' => 'Login',
			'login.apiUrlLabel' => 'API URL',
			'login.loginButton' => 'Login',
			'login.authFailedNoToken' => 'Authentication failed: No token received',
			'login.authFailedMessage' => ({required Object error}) => 'Authentication failed: ${error}',
			'edit.save' => 'Save',
			'edit.toast' => 'Changes saved',
			'edit.retry' => 'Retry',
			'edit.title' => 'Edit Link',
			'edit.fields.title' => 'Title',
			'edit.fields.url' => 'URL',
			'edit.fields.note' => 'Note',
			'edit.fields.favorite' => 'Favorite',
			'edit.fields.archive' => 'Archive',
			'editBar.title' => ({required Object count}) => '${count} items',
			'editBar.cancel' => 'Cancel selection',
			'editBar.more' => 'More actions',
			'editBar.deletePrompt' => ({required Object count}) => 'Delete ${count} links permanently?',
			'editBar.deleteWarning' => 'This is permanent and cannot be undone.',
			'filter.archive.title' => 'Archive',
			'filter.archive.all' => 'All',
			'filter.archive.oui' => 'Archived',
			'filter.archive.non' => 'Not Archived',
			'filter.favorite.title' => 'Favorite',
			'filter.favorite.all' => 'All',
			'filter.favorite.oui' => 'Favorited',
			'filter.favorite.non' => 'Not Favorited',
			'filter.order.title' => 'Order',
			'filter.order.newestFirst' => 'Newest First',
			'filter.order.oldestFirst' => 'Oldest First',
			'linkAction.archive' => 'Archive',
			'linkAction.unarchive' => 'Unarchive',
			'linkAction.favorite' => 'Favorite',
			'linkAction.unfavorite' => 'Unfavorite',
			'linkAction.select' => 'Select',
			'linkAction.edit' => 'Edit',
			'linkAction.share' => 'Share',
			'linkAction.delete' => 'Delete',
			_ => null,
		};
	}
}
