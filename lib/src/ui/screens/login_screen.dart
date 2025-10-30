import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  final AuthService authService;
  const LoginScreen({required this.authService, super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtl = TextEditingController();
  final _passCtl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtl.dispose();
    _passCtl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final email = _emailCtl.text.trim();
    final pass = _passCtl.text;
    final user = await widget.authService.login(email, pass);
    setState(() => _loading = false);
    if (user == null) {
      setState(() {
        _error = 'Invalid email or password';
      });
      return;
    }
    /* Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => HomeScreen(authService: widget.authService),
      ),
    ); */
    context.go('/teacher/stories');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hikayati — Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _emailCtl,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Enter email' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passCtl,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Enter password' : null,
                  ),
                  const SizedBox(height: 12),
                  if (_error != null)
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _loading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) _login();
                          },
                    child: _loading
                        ? const CircularProgressIndicator()
                        : const Text('Login'),
                  ),
                  TextButton(
                    onPressed: () {
                      /* Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              RegisterScreen(authService: widget.authService),
                        ),
                      ); */

                      context.go('/register');
                    },
                    child: const Text('Create a teacher account'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// import placed at bottom to avoid circular import during copy-paste
