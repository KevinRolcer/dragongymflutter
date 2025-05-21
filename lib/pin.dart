import 'package:flutter/material.dart';
import 'screens/home.dart';
import 'package:flutter/services.dart';
import 'service/pin_service.dart';
import 'dart:async';

class PinScreen extends StatefulWidget {
  final String? telefonoInicial;

  PinScreen({this.telefonoInicial});

  @override
  _PinScreenState createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> with SingleTickerProviderStateMixin {
  String pin = '';
  String repetirPin = '';
  bool pasoConfirmacion = false;

  String? telefono;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    telefono = widget.telefonoInicial;

    _shakeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 8).chain(CurveTween(curve: Curves.elasticIn)).animate(_shakeController);
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void agregarDigitoPin(String digito) {
    HapticFeedback.mediumImpact();
    setState(() {
      if (!pasoConfirmacion && pin.length < 4) {
        pin += digito;
        if (pin.length == 4) {
          pasoConfirmacion = true;
        }
      } else if (pasoConfirmacion && repetirPin.length < 4) {
        repetirPin += digito;
      }
    });
  }


  void borrarDigitoPin() {
    HapticFeedback.mediumImpact();
    setState(() {
      if (!pasoConfirmacion && pin.isNotEmpty) {
        pin = pin.substring(0, pin.length - 1);
      } else if (pasoConfirmacion && repetirPin.isNotEmpty) {
        repetirPin = repetirPin.substring(0, repetirPin.length - 1);
      }
    });
  }


  void _triggerShake() {
    HapticFeedback.mediumImpact();
    _shakeController.forward(from: 0);
  }


  void validarPin() async {
    if (pin != repetirPin) {
      _triggerShake();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Los PINs no coinciden', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent,
        ),
      );
      setState(() {
        repetirPin = '';
      });
    } else {
      await PinService().actualizarPin(telefono!, int.parse(pin));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PIN creado exitosamente', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.green,
        ),
      );

      Future.delayed(Duration(seconds: 1), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomePage()),
        );
      });
    }
  }

  Widget construirIndicadorPin(String valor) {
    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        double offset = _shakeController.status == AnimationStatus.forward || _shakeController.status == AnimationStatus.reverse
            ? _shakeAnimation.value * (1 - 2 * (child.hashCode % 2)) // para alternar izquierda/derecha
            : 0;
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 8),
          width: 14,
          height: 14,
          transform: Matrix4.translationValues(offset, 0, 0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: valor.length >= 1 ? Colors.redAccent : Colors.white.withOpacity(0.3),
          ),
        );
      },
      child: Container(),
    );
  }

  @override
  Widget build(BuildContext context) {
    String titulo = pasoConfirmacion ? 'Repite tu PIN' : 'Crea tu PIN';
    String entradaActual = pasoConfirmacion ? repetirPin : pin;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: pasoConfirmacion
            ? IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            setState(() {
              pasoConfirmacion = false;
              repetirPin = '';
            });
          },
        )
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 80, bottom: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Text(
                  titulo,
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                      4, (index) => construirIndicadorPin(entradaActual.length > index ? '●' : '')),
                ),
                SizedBox(height: 20),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                children: [
                  for (var fila in [
                    ['1', '2', '3'],
                    ['4', '5', '6'],
                    ['7', '8', '9'],
                    ['', '0', '⌫']
                  ])
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: fila.map((valor) {
                        if (valor == '') {
                          return SizedBox(width: 60);
                        }
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () {
                              valor == '⌫' ? borrarDigitoPin() : agregarDigitoPin(valor);
                            },
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white10,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: valor == '⌫'
                                    ? Icon(Icons.backspace_outlined, color: Colors.white)
                                    : Text(valor, style: TextStyle(fontSize: 22, color: Colors.white)),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  SizedBox(height: 20),
                  if (pasoConfirmacion && repetirPin.length == 4)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: EdgeInsets.symmetric(horizontal: 60, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: validarPin,
                      child: Text("Crear", style: TextStyle(color: Colors.white, fontSize: 18)),
                    )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
