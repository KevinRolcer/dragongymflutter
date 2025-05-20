import 'package:flutter/material.dart';
import 'service/login_service.dart'; 
import 'screens/codigo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  late AnimationController _controller1;
  late AnimationController _controller2;

  late Animation<double> _opacity1;
  late Animation<double> _opacity2;

  final TextEditingController telefonoController = TextEditingController();
  final LoginService loginService = LoginService();

  @override
  void initState() {
    super.initState();

    _controller1 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _controller2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _opacity1 = Tween<double>(begin: 0, end: 1).animate(_controller1);
    _opacity2 = Tween<double>(begin: 0, end: 1).animate(_controller2);

    _controller1.forward();
    Future.delayed(const Duration(milliseconds: 800), () {
      _controller2.forward();
    });
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    telefonoController.dispose();
    super.dispose();
  }

  Future<void> validarTelefono() async {
    String numero = telefonoController.text.trim();

    if (numero.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa un número de teléfono')),
      );
      return;
    }

    final respuesta = await loginService.buscarUsuario(numero);

    if (respuesta["success"] == true) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CodigoScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(respuesta["mensaje"] ?? 'Error desconocido')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 30,
          ),
          child: Center(
            child: Column(
              children: [
                Image.asset(
                  'assets/dragonLogoSn.png',
                  width: 120,
                  height: 120,
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: 280,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeTransition(
                          opacity: _opacity1,
                          child: const Text(
                            'Hey,',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 38,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        FadeTransition(
                          opacity: _opacity2,
                          child: const Text(
                            'Bienvenido de nuevo',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 38,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                SizedBox(
                  width: 280,
                  child: TextField(
                    controller: telefonoController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Número de teléfono',
                      hintStyle: const TextStyle(color: Colors.white54),
                      prefixIcon: const Icon(Icons.phone, color: Colors.white54),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: 280,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: validarTelefono,
                    child: const Text(
                      'Validar número',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
