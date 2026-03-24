import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../i18n/strings.g.dart';
import '../providers/bindings/shared_preferences.dart';
import '../repositories/api.dart';
import '../validators/url.dart';

final _logger = Logger('LoginPage');

class _LoginAction {
  _LoginAction(this.context, this.ref)
    : form = _buildForm(ref),
      isLoading = useState(false);

  final BuildContext context;
  final WidgetRef ref;

  final FormGroup form;
  final ValueNotifier<bool> isLoading;

  static FormGroup _buildForm(WidgetRef ref) {
    final form = useMemoized(
      () => FormGroup({
        'apiUrl': FormControl<String>(
          validators: [Validators.required, const AbsoluteUrlValidator()],
        ),
      }),
    );

    final apiUrl = ref.watch(preferenceProvider(SharedPreferenceKey.apiUrl));

    // Initialize form with saved API URL
    useEffect(() {
      final value = apiUrl.value;
      if (value != null) {
        form.control('apiUrl').value = value;
      }

      return null;
    }, [apiUrl]);

    return form;
  }

  Future<void> submit() async {
    // Disable button if another submission is in flight
    if (isLoading.value) {
      return;
    }

    // Make sure the form is up to date and valid
    form.updateValueAndValidity();
    if (form.invalid) {
      return;
    }

    isLoading.value = true;

    try {
      final value = form.control("apiUrl").value as String;
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

      await ref
          .read(preferenceProvider(SharedPreferenceKey.apiToken).notifier)
          .set(token);
      await ref
          .read(preferenceProvider(SharedPreferenceKey.apiUrl).notifier)
          .set(apiUrl);

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
    } catch (e) {
      // FIXME: Error translation
      throw Exception('Unable to connect to server. Is the URL correct?: $e');
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = _LoginAction(context, ref);

    final form = actions.form;
    final isLoading = actions.isLoading;

    return Scaffold(
      appBar: AppBar(title: Text(t.login.title)),
      body: Center(
        child: ReactiveForm(
          formGroup: form,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ReactiveTextField(
                  formControlName: 'apiUrl',
                  decoration: InputDecoration(labelText: t.login.apiUrlLabel),
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
        ),
      ),
    );
  }
}
