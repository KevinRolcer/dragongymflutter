import 'package:flutter/material.dart';
import 'screens/home.dart';
import 'package:flutter/services.dart';
import 'service/pin_service.dart';
import 'dart:async';
import 'package:dragongym/values/app_colors.dart';


class AccesoScreen extends StatefulWidget {
  final String? telefonoInicial;

  AccesoScreen({this.telefonoInicial});

  @override
  _AccesoScreenState createState() => _AccesoScreenState();
}

class _AccesoScreenState extends State<AccesoScreen> with SingleTickerProviderStateMixin {
  String pinIngresado = '';
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

    _shakeAnimation = Tween<double>(begin: 0, end: 8)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void agregarDigito(String digito) {
    HapticFeedback.mediumImpact();
    if (pinIngresado.length < 4) {
      setState(() {
        pinIngresado += digito;
      });

      if (pinIngresado.length == 4) {
        _validarPin();
      }
    }
  }

  void borrarDigito() {
    HapticFeedback.mediumImpact();
    if (pinIngresado.isNotEmpty) {
      setState(() {
        pinIngresado = pinIngresado.substring(0, pinIngresado.length - 1);
      });
    }
  }

  void _triggerShake() {
    HapticFeedback.mediumImpact();
    _shakeController.forward(from: 0);
  }

  void _validarPin() async {
    final respuesta = await PinService().validarPin(telefono!, int.parse(pinIngresado));

    if (respuesta.containsKey('success')) {
      bool valido = respuesta['success'] == true;

      if (valido) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PIN correcto', style: TextStyle(color: Colors.white)),
            backgroundColor: AppColors.primaryColor,
          ),
        );

        await Future.delayed(Duration(seconds: 1));

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomePage()),
          );
        }
      }
      else {
        _triggerShake();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PIN incorrecto', style: TextStyle(color: AppColors.primaryColor)),
            backgroundColor: AppColors.primaryColor,
          ),
        );
        setState(() {
          pinIngresado = '';
        });
      }
    } else {
      _triggerShake();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(respuesta['mensaje'] ?? 'Error desconocido', style: TextStyle(color: Colors.white)),
          backgroundColor: AppColors.primaryColor,
        ),
      );
      setState(() {
        pinIngresado = '';
      });
    }
  }


  Widget construirIndicadorPin(String valor) {
    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        double offset = _shakeController.status == AnimationStatus.forward || _shakeController.status == AnimationStatus.reverse
            ? _shakeAnimation.value * (1 - 2 * (child.hashCode % 2))
            : 0;
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 8),
          width: 14,
          height: 14,
          transform: Matrix4.translationValues(offset, 0, 0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: valor.length >= 1 ? AppColors.primaryColor : Colors.white.withOpacity(0.3),
          ),
        );
      },
      child: Container(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blackBack,
      appBar: AppBar(
        backgroundColor: AppColors.blackBack,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 80, bottom: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Text(
                  'Ingresa tu PIN',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) => construirIndicadorPin(pinIngresado.length > index ? '●' : '')),
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
                              valor == '⌫' ? borrarDigito() : agregarDigito(valor);
                            },
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: AppColors.darkMode,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
