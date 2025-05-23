import 'package:flutter/material.dart';
import '../model/promos.dart';
import '../service/promo_service.dart';
import 'package:dragongym/values/app_colors.dart';


class PromoScreen extends StatefulWidget {
  @override
  _PromoScreenState createState() => _PromoScreenState();
}

class _PromoScreenState extends State<PromoScreen> {
  int _selectedIndex = 1;

  List<Promo> promos = [];
  @override
  void initState() {
    super.initState();
    cargarPromociones().then((_) {
      setState(() {});
    });
  }

  Future<void> cargarPromociones() async {
    final servicio = PromoService();
    final respuesta = await servicio.obtenerPromociones();

    if (respuesta['success']) {
      final datos = respuesta['data'] as List;

      promos = datos.map((item) => Promo.fromJson(item)).toList();

      print("Promociones cargadas: ${promos.length}");
    } else {
      print("Error: ${respuesta['mensaje']}");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkMode,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildPromosList(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
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

  Widget _buildPromosList() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Promociones Disponibles",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.backgroundColor,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Descuentos y ofertas especiales",
            style: TextStyle(
              fontSize: 16,
              color: AppColors.redColor,
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: promos.length,
              itemBuilder: (context, index) {
                return _buildPromoCard(promos[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCard(Promo promo) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () => _showPromoDetails(promo),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      promo.offerText,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        promo.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.backgroundColor,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        promo.subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.grayColor,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Válido hasta: ${promo.formattedValidUntil}",
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.redColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.backgroundColor,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPromoDetails(Promo promo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.secondColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [

                Container(
                  margin: EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  promo.offerText,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    promo.title,
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.backgroundColor,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    promo.subtitle,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: AppColors.redColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24),

                        Text(
                          "Descripción",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.backgroundColor,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          promo.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.grayColor,
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: 20),

                        Text(
                          "Términos y Condiciones",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.backgroundColor,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          promo.terms,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.grayColor,
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: 20),

                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                color: AppColors.primaryColor,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Válido hasta: ${promo.formattedValidUntil}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.backgroundColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24),

                        Container(
                          width: double.infinity,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 200,
                                height: 40,
                                child: CustomPaint(
                                  painter: BarcodePainter(),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "#${promo.id}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);

                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(
                        "Cerrar promoción",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
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
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'Alertas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.discount),
              label: 'Promos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.money),
              label: 'Membresía',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}

class BarcodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;

    final double width = size.width;
    final double height = size.height;

    for (int i = 0; i < 40; i++) {
      final double x = (width / 40) * i;
      final bool isThick = i % 3 == 0;
      paint.strokeWidth = isThick ? 3 : 1;

      canvas.drawLine(
        Offset(x, 0),
        Offset(x, height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}