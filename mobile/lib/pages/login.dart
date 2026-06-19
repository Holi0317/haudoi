import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:url_launcher/url_launcher.dart';

import '../hooks/globalkey.dart';
import '../i18n/strings.g.dart';
import '../providers/api/auth.dart';
import '../providers/bindings/shared_preferences.dart';
import '../repositories/api.dart';
import '../repositories/api_error.dart';

final _logger = Logger('LoginPage');

const _githubUrl = 'https://github.com/Holi0317/haudoi';

enum _LoginProvider { github, google }

class _LoginAction {
  _LoginAction(this.context, this.ref)
    : formKey = useFormBuilderKey(),
      isLoading = useState(false),
      selectedProvider = useState(_LoginProvider.github);

  final BuildContext context;
  final WidgetRef ref;

  final GlobalKey<FormBuilderState> formKey;
  final ValueNotifier<bool> isLoading;
  final ValueNotifier<_LoginProvider> selectedProvider;

  Future<void> submit() async {
    // Disable button if another submission is in flight
    if (isLoading.value) {
      return;
    }

    final form = formKey.currentState!;

    // Validate and save the form values
    if (!form.saveAndValidate()) {
      return;
    }

    isLoading.value = true;

    try {
      final value = form.value["apiUrl"] as String;
      final u = Uri.parse(value);
      final apiUrl = u.replace(path: "/api").toString();
      final loginUrl = u
          .replace(
            path: "/auth/${selectedProvider.value.name}/login",
            query: "redirect=haudoi:",
          )
          .toString();

      // Validate server info on URL
      await _validateServer(apiUrl);

      // Authenticate with GitHub and get authorized callback URL
      final token = await _oauthLogin(loginUrl);
      if (token.isEmpty) {
        _showSnackBar(t.login.authFailedNoToken);
        return;
      }

      await ref.read(authProvider.notifier).login(apiUrl: apiUrl, token: token);

      if (context.mounted) {
        context.go('/unread');
      }
    } catch (e, st) {
      _logger.severe('Authentication failed', e, st);

      _showSnackBar(t.login.authFailedMessage(error: e.toString()));
    } finally {
      if (context.mounted) {
        isLoading.value = false;
      }
    }
  }

  Future<void> _validateServer(String apiUrl) async {
    final httpClient = http.Client();
    final apiRepository = ApiRepository(
      transport: httpClient,
      baseUrl: apiUrl,
      authToken: '',
    );

    _logger.info('Validating server at $apiUrl');

    try {
      await apiRepository.info();
    } on TransportApiError catch (e) {
      _logger.warning('Server unreachable at $apiUrl', e);
      throw Exception(t.login.serverUnreachable);
    } on KnownServerApiError catch (e) {
      _logger.warning('Server error at $apiUrl: ${e.model.code}', e);
      throw Exception(t.login.serverError(message: e.model.message));
    } on ApiError catch (e) {
      _logger.warning('Invalid server response at $apiUrl', e);
      throw Exception(t.login.serverInvalidResponse);
    }

    _logger.info('Server at $apiUrl is valid');
  }

  Future<String> _oauthLogin(String loginUrl) async {
    final result = await FlutterWebAuth2.authenticate(
      url: loginUrl,
      callbackUrlScheme: 'haudoi',
    );

    // Extract token from callback URL
    final uri = Uri.parse(result);
    final token = uri.queryParameters['token'] ?? '';

    return token;
  }

  void _showSnackBar(String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }
}

class LoginPage extends HookConsumerWidget {
  const LoginPage({super.key});

  Future<void> openGithub() async {
    final uri = Uri.parse(_githubUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = _LoginAction(context, ref);
    final formKey = actions.formKey;
    final isLoading = actions.isLoading;
    final selectedProvider = actions.selectedProvider;

    final recentServers = ref.watch(recentServersProvider);

    return Scaffold(
      appBar: AppBar(title: Text(t.login.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.bookmark,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Haudoi',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              t.login.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: openGithub,
              icon: const Icon(Icons.open_in_new),
              label: Text(t.login.viewOnGithub),
            ),
            const SizedBox(height: 32),
            Text(
              t.login.loginProvider,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            SegmentedButton<_LoginProvider>(
              segments: [
                ButtonSegment<_LoginProvider>(
                  value: _LoginProvider.github,
                  label: Text(t.login.providerGithub),
                ),
                ButtonSegment<_LoginProvider>(
                  value: _LoginProvider.google,
                  label: Text(t.login.providerGoogle),
                ),
              ],
              selected: {selectedProvider.value},
              onSelectionChanged: (Set<_LoginProvider> newSelection) {
                selectedProvider.value = newSelection.first;
              },
            ),
            const SizedBox(height: 32),
            Text(
              t.login.apiUrlInstructions,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),

            FormBuilder(
              key: formKey,
              enabled: !recentServers.isLoading,
              child: switch (recentServers) {
                AsyncValue(hasError: true) => _ServerUrlField(
                  formKey: formKey,
                  isLoading: isLoading,
                  recentServers: const [],
                  initialValue: '',
                  onRemove: (_) {},
                ),
                AsyncValue(:final value?, hasValue: true) => _ServerUrlField(
                  formKey: formKey,
                  isLoading: isLoading,
                  recentServers: value,
                  initialValue: value.isNotEmpty ? value.first : '',
                  onRemove: (server) {
                    ref.read(recentServersProvider.notifier).remove(server);
                  },
                ),
                _ => const LinearProgressIndicator(),
              },
            ),

            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isLoading.value)
                  const SizedBox(
                    width: 48,
                    height: 40,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
                  FilledButton(
                    style: TextButton.styleFrom(
                      textStyle: Theme.of(context).textTheme.labelLarge,
                    ),
                    onPressed: actions.submit,
                    child: Text(t.login.loginButton),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ServerUrlField extends HookWidget {
  const _ServerUrlField({
    required this.formKey,
    required this.isLoading,
    required this.recentServers,
    required this.initialValue,
    required this.onRemove,
  });

  final GlobalKey<FormBuilderState> formKey;
  final ValueNotifier<bool> isLoading;
  final List<String> recentServers;
  final String initialValue;
  final void Function(String) onRemove;

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      // Invalidate the entire widget when recent servers list changes to update suggestions
      key: ValueKey(Object.hashAll(recentServers)),
      initialValue: TextEditingValue(text: initialValue),
      optionsBuilder: (TextEditingValue textValue) {
        if (textValue.text.isEmpty || recentServers.isEmpty) {
          return const Iterable<String>.empty();
        }
        final lowerText = textValue.text.toLowerCase();
        return recentServers.where(
          (server) => server.toLowerCase().contains(lowerText),
        );
      },
      onSelected: (String selection) {
        formKey.currentState?.patchValue({'apiUrl': selection});
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return FormBuilderTextField(
          name: 'apiUrl',
          controller: controller,
          focusNode: focusNode,
          enabled: !isLoading.value,
          decoration: InputDecoration(
            labelText: t.login.apiUrlLabel,
            hintText: t.login.apiUrlHint,
          ),
          keyboardType: TextInputType.url,
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(),
            FormBuilderValidators.url(
              protocols: ["http", "https"],
              requireTld: false,
            ),
          ]),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 200,
                maxWidth: MediaQuery.of(context).size.width - 48,
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final server = options.elementAt(index);
                  return ListTile(
                    dense: true,
                    title: Text(server, overflow: TextOverflow.ellipsis),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, size: 18),
                      onPressed: () {
                        onRemove(server);
                      },
                      tooltip: t.dialogs.delete,
                    ),
                    onTap: () => onSelected(server),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
