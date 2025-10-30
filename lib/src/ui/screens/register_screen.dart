import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  final AuthService authService;
  const RegisterScreen({required this.authService, super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtl = TextEditingController();
  final _nameCtl = TextEditingController();
  final _passCtl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtl.dispose();
    _nameCtl.dispose();
    _passCtl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final user = await widget.authService.registerTeacher(
        _emailCtl.text.trim(),
        _nameCtl.text.trim(),
        _passCtl.text,
      );
      setState(() => _loading = false);
      /* Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => HomeScreen(authService: widget.authService),
        ),
        (_) => false,
      ); */
      context.go('/home');
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Registration failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register Teacher')),
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
                    controller: _nameCtl,
                    decoration: const InputDecoration(
                      labelText: 'Display name',
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Enter name' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passCtl,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (v) =>
                        (v == null || v.length < 4) ? 'Min 4 chars' : null,
                  ),
                  const SizedBox(height: 12),
                  if (_error != null)
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _loading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) _register();
                          },
                    child: _loading
                        ? const CircularProgressIndicator()
                        : const Text('Register'),
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
