import 'package:flutter/material.dart';
import 'package:dragongym/values/app_colors.dart';
import '../model/planes.dart';
import '../service/planes_service.dart';


class MembresiaScreen extends StatefulWidget {
  @override
  _MembresiaScreenState createState() => _MembresiaScreenState();
}

class _MembresiaScreenState extends State<MembresiaScreen> {

  int _selectedIndex = 3;
  List<Planes> membresias = [];


  @override
  void initState() {
    super.initState();
    cargarMembresias();
  }

  Future<void> cargarMembresias() async {
    final servicio = PlanesService();
    final respuesta = await servicio.obtenerPlanes();

    if (respuesta['success'] == true && respuesta['planes'] != null) {
      List datos = respuesta['planes'];
      setState(() {
        membresias = datos.map((plan) => Planes.fromJson(plan)).toList();
      });
    } else {
      print("Error al obtener planes: ${respuesta['mensaje']}");
    }
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.blackBack,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.grid_view,
              color: AppColors.backgroundColor,
            ),
          ),
          Spacer(),
          Icon(
            Icons.notifications_outlined,
            color: AppColors.primaryColor,
            size: 24,
          ),
          SizedBox(width: 16),
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.blackBack,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.add,
              color: AppColors.backgroundColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondColor,
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
              case 4:
                Navigator.pushNamed(context, '/perfil');
                break;
            }
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.backgroundColor,
          unselectedItemColor: AppColors.backgroundColor,
          selectedIconTheme: IconThemeData(color: AppColors.primaryColor),
          unselectedIconTheme: IconThemeData(color: AppColors.backgroundColor),
          backgroundColor: AppColors.secondColor,
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

  Widget _buildMembresiaCard(Planes membresia) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                membresia.tipo,
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'No. ${membresia.idMembresia}',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '\$${membresia.costo.toStringAsFixed(2)}',
            style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Descripción: ${membresia.descripcion}',
              style: TextStyle(color: AppColors.redColor, fontSize: 14),
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Duración: ${membresia.duracion}',
              style: TextStyle(color: Colors.white60, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembresiasList() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: membresias.map((membresia) => _buildMembresiaCard(membresia)).toList(),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: AppColors.darkMode,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              _buildHeader(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Membresías Disponibles",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.backgroundColor,
                  ),
                ),
              ),
              SizedBox(height: 20),
              _buildMembresiasList(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
}
