import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/navigation/routes.dart';
import '../../core/session/session_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/ui/app_form_field.dart';
import '../../core/ui/app_top_bar.dart';
import '../../core/utils/validators.dart';

/// ============================================================
///  ADMIN — ÉCRAN DE CONNEXION
/// ============================================================
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'admin@doken.com');
  final _passwordController = TextEditingController(text: 'Admin1234');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    if (ref.read(sessionProvider).isLoading) return;

    if (!_formKey.currentState!.validate()) return;

    final ok = await ref.read(sessionProvider.notifier).login(
          _emailController.text,
          _passwordController.text,
        );

    if (ok && mounted) {
      context.go(AppRoutes.home);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bienvenue ! Noyau de dispatch en ligne.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);

    return Scaffold(
      appBar: const AppTopBar(
        title: 'Connexion Admin',
        showBackButton: false,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimens.space24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppDimens.space12),
                    Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(
                            AppDimens.radius20,
                          ),
                        ),
                        child: const Icon(
                          Icons.admin_panel_settings_outlined,
                          size: 38,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimens.space16),
                    Text(
                      'Portail d\'administration',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: AppDimens.space8),
                    Text(
                      'Connectez-vous pour gérer les commandes et les livreurs',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: AppDimens.space32),

                    // Message d'erreur s'il y a lieu
                    if (session.authError != null) ...[
                      Container(
                        padding: const EdgeInsets.all(AppDimens.space12),
                        decoration: BoxDecoration(
                          color: AppColors.errorSoft,
                          borderRadius:
                              BorderRadius.circular(AppDimens.radius12),
                          border: Border.all(color: AppColors.error),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: AppColors.error,
                              size: 20,
                            ),
                            const SizedBox(width: AppDimens.space12),
                            Expanded(
                              child: Text(
                                session.authError!,
                                style: const TextStyle(
                                  color: AppColors.error,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDimens.space20),
                    ],

                    // Champ E-mail
                    AppFormField(
                      label: 'Adresse e-mail',
                      hint: 'admin@doken.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email,
                      prefixIcon: const Icon(Icons.email_outlined),
                      enabled: !session.isLoading,
                    ),
                    const SizedBox(height: AppDimens.space16),

                    // Champ Mot de passe
                    AppFormField(
                      label: 'Mot de passe',
                      hint: '••••••••',
                      controller: _passwordController,
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      validator: Validators.password,
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      enabled: !session.isLoading,
                      onFieldSubmitted: (_) => _submitLogin(),
                    ),
                    const SizedBox(height: AppDimens.space24),

                    // Bouton Se connecter avec état de chargement
                    ElevatedButton(
                      onPressed: session.isLoading ? null : _submitLogin,
                      child: session.isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppColors.onPrimary,
                              ),
                            )
                          : const Text('Se connecter'),
                    ),
                    const SizedBox(height: AppDimens.space24),

                    // Indication compte de démo
                    Container(
                      padding: const EdgeInsets.all(AppDimens.space12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAlt,
                        borderRadius:
                            BorderRadius.circular(AppDimens.radius12),
                      ),
                      child: const Text(
                        'Compte de démo : admin@doken.com / Admin1234\nTest d\'échec : fail@doken.com',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
