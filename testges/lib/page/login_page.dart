import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../service/auth_service.dart';
import '../service/authentication_provider.dart';
import 'reset_password_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _authService.login(_emailController.text, _passwordController.text);
      final token = response['token'];
      if (token != null) {
        await ref.read(authenticationProvider.notifier).setToken(token); // Stocker le token
      } else {
        _showErrorDialog('Impossible de se connecter, vérifiez vos identifiants');
      }
    } catch (e) {
      _showErrorDialog('Impossible de se connecter, vérifiez vos identifiants');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Erreur'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.yellow[700]!, Colors.orange[700]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ScaleTransition(
                scale: _animation,
                child: Text(
                  'GeSign',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 40),
              FadeTransition(
                opacity: _animation,
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
              SizedBox(height: 20),
              FadeTransition(
                opacity: _animation,
                child: TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                  ),
                  obscureText: true,
                ),
              ),
              SizedBox(height: 20),
              if (_errorMessage != null)
                FadeTransition(
                  opacity: _animation,
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              SizedBox(height: 20),
              if (_isLoading)
                CircularProgressIndicator()
              else
                FadeTransition(
                  opacity: _animation,
                  child: ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange, // background (button) color
                      foregroundColor: Colors.white, // foreground (text) color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                    child: Text('Login'),
                  ),
                ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ResetPasswordPage()),
                  );
                },
                child: Text('Mot de passe oublié ?'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white, // Text color
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
