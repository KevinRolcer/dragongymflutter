import 'package:flutter/material.dart';
import 'package:dragongym/values/app_colors.dart';
import 'package:provider/provider.dart';
import '../service/usuario_provider.dart';
import '../model/perfil.dart';
import '../model/membresia.dart';
import '../service/perfil_service.dart';
import '../service/pin_service.dart';



class PerfilScreen extends StatefulWidget {
  @override
  _PerfilScreenState createState() => _PerfilScreenState();
}



class _PerfilScreenState extends State<PerfilScreen> {
  int _selectedIndex = 4;
  String _pin = "";
  final PinService _pinService = PinService();


  void _editarPIN() {
    final telefono = Provider.of<UsuarioProvider>(context, listen: false).telefono;

    if (telefono == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Teléfono no disponible'), backgroundColor: Colors.red),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String nuevoPin = '';
        List<TextEditingController> controladores = List.generate(4, (_) => TextEditingController());
        List<FocusNode> focusNodes = List.generate(4, (_) => FocusNode());

        WidgetsBinding.instance.addPostFrameCallback((_) {
          focusNodes[0].requestFocus();
        });

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            "Editar PIN",
            style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) {
                  return Container(
                    width: 50,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primaryColor, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: TextField(
                      controller: controladores[index],
                      focusNode: focusNodes[index],
                      maxLength: 1,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        counterText: '',
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && RegExp(r'^\d$').hasMatch(value)) {
                          if (index < 3) {
                            focusNodes[index + 1].requestFocus();
                          } else {
                            focusNodes[index].unfocus();
                          }
                        } else if (value.isEmpty && index > 0) {
                          focusNodes[index - 1].requestFocus();
                        }
                      },
                      onSubmitted: (value) {
                        if (index < 3) {
                          focusNodes[index + 1].requestFocus();
                        }
                      },
                    ),
                  );
                }),
              ),
              SizedBox(height: 10),
              Text(
                "Ingresa tu nuevo PIN de 4 dígitos",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text(
                "Cancelar",
                style: TextStyle(color: Colors.grey[600]),
              ),
              onPressed: () {
                for (var node in focusNodes) {
                  node.dispose();
                }
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                "Guardar",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                nuevoPin = controladores.map((c) => c.text).join();
                if (nuevoPin.length == 4 && RegExp(r'^\d{4}$').hasMatch(nuevoPin)) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => Center(child: CircularProgressIndicator()),
                  );

                  final resultado = await _pinService.actualizarPin(telefono.toString(), int.parse(nuevoPin));

                  Navigator.pop(context);

                  if (resultado['success'] == true) {
                    setState(() {
                      _pin = nuevoPin;
                    });
                    for (var node in focusNodes) {
                      node.dispose();
                    }
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("PIN actualizado correctamente"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Error al actualizar PIN: ${resultado['mensaje']}"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Por favor ingresa un PIN válido de 4 dígitos"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            )

          ],
        );
      },
    );
  }

  Widget _buildDato(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              "$label:",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionContainer(String title, List<Widget> children, {Widget? actionButton}) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
                if (actionButton != null) actionButton,
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });

            switch (index) {
              case 1:
                Navigator.pushNamed(context, '/promo');
                break;
              case 2:
                Navigator.pushNamed(context, '/home');
                break;
            }
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primaryColor,
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          elevation: 0,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Alertas'),
            BottomNavigationBarItem(icon: Icon(Icons.discount), label: 'Promos'),
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
            BottomNavigationBarItem(icon: Icon(Icons.money), label: 'Membresía'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final telefono = Provider.of<UsuarioProvider>(context).telefono;
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'Perfil',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(

                future: PerfilService().obtenerPerfilPorTelefono("$telefono"),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!['success'] != true) {
                    return Center(child: Text("Error al cargar datos"));
                  }

                  final perfil = Perfil.fromJson(snapshot.data!['perfil']);
                  final membresia = Membresia.fromJson(snapshot.data!['membresia']);

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ListView(
                      children: [
                        _buildSectionContainer(
                          "Datos del Perfil",
                          [
                            _buildDato("ID Miembro", perfil.idMiembro.toString()),
                            _buildDato("Nombre", perfil.nombre.toString()),
                            _buildDato("Apellido P", perfil.apellidoP.toString()),
                            _buildDato("Apellido M", perfil.apellidoM.toString()),
                            _buildDato("Sexo", perfil.sexo.toString()),
                            _buildDato("Teléfono", perfil.telefono.toString()),
                            _buildDato("Estatus", perfil.estatus.toString()),
                            _buildDato("PIN", perfil.pin.toString()),
                          ],
                          actionButton: TextButton.icon(
                            onPressed: _editarPIN,
                            icon: Icon(Icons.edit, size: 16, color: AppColors.primaryColor),
                            label: Text(
                              "Editar PIN",
                              style: TextStyle(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        _buildSectionContainer(
                          "Membresía",
                          [
                            _buildDato("ID Miembro", membresia.idMiembro.toString()),
                            _buildDato("Fecha Inicio", membresia.fechaInicio.toString()),
                            _buildDato("Fecha Fin", membresia.fechaFin.toString()),
                            _buildDato("Fecha Pago", membresia.fechaPago.toString()),
                            _buildDato("ID Membresía", membresia.idMembresia.toString()),
                          ],
                        ),
                        SizedBox(height: 100),
                      ],
                    ),
                  );
                },
              ),
            ),

          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
}