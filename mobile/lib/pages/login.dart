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

const _githubUrl = 'https://github.com/anomalyco/haudoi';

class _LoginAction {
  _LoginAction(this.context, this.ref)
    : formKey = useFormBuilderKey(),
      isLoading = useState(false);

  final BuildContext context;
  final WidgetRef ref;

  final GlobalKey<FormBuilderState> formKey;
  final ValueNotifier<bool> isLoading;

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
          .replace(path: "/auth/github/login", query: "redirect=haudoi:")
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

    final apiUrl = ref.watch(preferenceProvider(SharedPreferenceKey.apiUrl));

    // Initialize form with saved API URL
    useEffect(() {
      final value = apiUrl.value;
      if (value != null && formKey.currentState != null) {
        formKey.currentState!.patchValue({'apiUrl': value});
      }

      return null;
    }, [apiUrl, formKey.currentState]);

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
              t.login.apiUrlInstructions,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            FormBuilder(
              key: formKey,
              enabled: !isLoading.value,
              child: Column(
                children: [
                  FormBuilderTextField(
                    name: 'apiUrl',
                    decoration: InputDecoration(
                      labelText: t.login.apiUrlLabel,
                      hintText: t.login.apiUrlHint,
                    ),
                    keyboardType: TextInputType.url,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.url(
                        protocols: ["http", "https"],
                        // Allow Tailscale MagicDNS and localhost domains
                        requireTld: false,
                      ),
                    ]),
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
          ],
        ),
      ),
    );
  }
}
