import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'pin.dart';

class CodigoScreen extends StatefulWidget {
  final String telefonoInicial;

  const CodigoScreen({super.key, required this.telefonoInicial});

  @override
  State<CodigoScreen> createState() => _CodigoScreenState();
}

class _CodigoScreenState extends State<CodigoScreen> with TickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _verificationId = "";
  bool _isLoading = false;

  bool _puedeReenviar = false;
  int _segundosRestantes = 60;
  Timer? _timer;

  List<String> _codigo = ["", "", "", "", "", ""];
  int _currentDigitIndex = 0;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isKeyboardVisible = false;

  List<AnimationController> _animControllers = [];
  List<Animation<double>> _animations = [];

  @override
  void initState() {
    super.initState();
    _enviarCodigo();
    _iniciarTemporizador();

    for (int i = 0; i < 6; i++) {
      AnimationController controller = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      );
      Animation<double> animation = Tween<double>(begin: 0.0, end: -15.0)
          .chain(CurveTween(curve: Curves.easeOutBack))
          .animate(controller);

      _animControllers.add(controller);
      _animations.add(animation);
    }

    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChange);

    Future.delayed(const Duration(milliseconds: 500), () {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  void _onFocusChange() {
    setState(() {
      _isKeyboardVisible = _focusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _animControllers) {
      controller.dispose();
    }
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _controller.text;

    setState(() {
      for (int i = 0; i < 6; i++) {
        if (i < text.length) {
          if (_codigo[i] != text[i]) {
            _codigo[i] = text[i];
            _playJumpAnimation(i);
          } else {
            _codigo[i] = text[i];
          }
        } else {
          _codigo[i] = "";
        }
      }

      _currentDigitIndex = text.length;
    });

    if (text.length == 6) {
      _verificarCodigo();
    }
  }

  void _playJumpAnimation(int index) {
    _animControllers[index].reset();
    _animControllers[index].forward();
  }

  void _iniciarTemporizador() {
    _puedeReenviar = false;
    _segundosRestantes = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_segundosRestantes == 0) {
        setState(() => _puedeReenviar = true);
        timer.cancel();
      } else {
        setState(() => _segundosRestantes--);
      }
    });
  }

  Future<void> _enviarCodigo() async {
    final telefonoConLada = "+52${widget.telefonoInicial}";
    setState(() => _isLoading = true);

    await _auth.verifyPhoneNumber(
      phoneNumber: telefonoConLada,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        _irAPin();
      },
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.message}")),
        );
        setState(() => _isLoading = false);
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Código enviado")),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  Future<void> _verificarCodigo() async {
    String codigoIngresado = _codigo.join();
    if (_verificationId.isEmpty || codigoIngresado.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ingresa un código válido de 6 dígitos")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: codigoIngresado,
      );

      await _auth.signInWithCredential(credential);
      _irAPin();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Código incorrecto, intenta nuevamente")),
      );
      setState(() {
        _codigo = ["", "", "", "", "", ""];
        _currentDigitIndex = 0;
        _isLoading = false;
        _controller.text = "";
      });
    }
  }

  void _irAPin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PinScreen(telefonoInicial: widget.telefonoInicial),
      ),
    );
  }

  void _reenviarCodigo() {
    if (_puedeReenviar) {
      _enviarCodigo();
      _iniciarTemporizador();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Reenviando código...")),
      );
    }
  }

  void _toggleKeyboard() {
    if (_isKeyboardVisible) {
      FocusScope.of(context).unfocus();
    } else {
      FocusScope.of(context).requestFocus(_focusNode);
      _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Verificación", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(_focusNode);
          },
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Código de verificación",
                      style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        "Porfavor ingresa el código mandado a\n+52${widget.telefonoInicial}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),

              Opacity(
                opacity: 0,
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: const InputDecoration(counterText: ""),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(right: 30, bottom: 8),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(
                      _isKeyboardVisible ? Icons.keyboard_hide : Icons.keyboard,
                      color: Colors.white,
                    ),
                    tooltip: _isKeyboardVisible ? 'Cerrar teclado' : 'Abrir teclado',
                    onPressed: _toggleKeyboard,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(6, (index) => _buildDigitBox(index)),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: TextButton(
                        onPressed: _puedeReenviar ? _reenviarCodigo : null,
                        child: Text(
                          _puedeReenviar
                              ? "Reenviar código"
                              : "Reenviar en $_segundosRestantes s",
                          style: TextStyle(
                            color: _puedeReenviar ? Colors.blue : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Center(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _verificarCodigo,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        minimumSize: const Size(200, 50),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : const Text(
                        "VALIDAR",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDigitBox(int index) {
    bool isActive = _codigo[index].isNotEmpty;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(_focusNode);
            _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
          },
          child: AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, isActive ? _animations[index].value : 0),
                child: Container(
                  height: 55,
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white.withOpacity(0.5) : Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _codigo[index],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}