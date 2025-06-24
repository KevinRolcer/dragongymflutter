import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:dragongym/values/app_colors.dart';
import '../service/accesos_service.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late DateTime _selectedDate;
  late List<DateTime> _weekDates;
  int _selectedIndex = 2;
  int? accesosActuales;
  int? capacidadMaxima;
  int? disponibilidad;
  String horaSugerida = '';
  bool cargando = true;
  String? mensajeError;


  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _generateWeekDays();
    _cargarEstadoGimnasio();
  }

  Widget _botonRefrescar() {
    return ElevatedButton(
      onPressed: () {
        setState(() {});
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        minimumSize: Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        'Refrescar estado',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Future<void> _cargarEstadoGimnasio() async {
    final servicio = AccesosService();
    final respuesta = await servicio.obtenerEstadoGimnasio();

    if (respuesta["success"] == true) {
      setState(() {
        accesosActuales = respuesta["accesos_actuales"];
        capacidadMaxima = respuesta["capacidad_maxima"];
        disponibilidad = respuesta["disponibilidad"];
        horaSugerida = respuesta["hora_sugerida"];
        cargando = false;
      });
    } else {
      setState(() {
        mensajeError = respuesta["mensaje"];
        cargando = false;
      });
    }
  }

  void _generateWeekDays() {
    DateTime now = DateTime.now();
    int weekDay = now.weekday;

    DateTime monday = now.subtract(Duration(days: weekDay - 1));

    _weekDates = List.generate(7, (index) =>
        DateTime(monday.year, monday.month, monday.day + index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blackBack,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildCalendar(),
            _buildDateInfo(),
            Expanded(
              child: _buildContent(),
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
              color: AppColors.secondColor,
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
              color: AppColors.secondColor,
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


  Widget _buildCalendar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (index) {
          final date = _weekDates[index];
          final isSelected = date.day == _selectedDate.day &&
              date.month == _selectedDate.month &&
              date.year == _selectedDate.year;

          final weekDayNames = ['Lu', 'Ma', 'Mi', 'Ju', 'Vi', 'Sa', 'Do'];

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
              });
            },
            child: Column(
              children: [
                Text(
                  weekDayNames[index],
                  style: TextStyle(
                    color: isSelected ? AppColors.primaryColor : Colors.white,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppColors.primaryColor : Colors.transparent,
                  ),
                  child: Center(
                    child: Text(
                      date.day.toString(),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDateInfo() {
    final formatter = DateFormat.yMMMd('es_ES');
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Text(
            'Hoy, ${formatter.format(_selectedDate)}',
            style: TextStyle(
              color: AppColors.backgroundColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: FutureBuilder<Map<String, dynamic>>(
        future: AccesosService().obtenerEstadoGimnasio(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data == null || snapshot.data!['success'] != true) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Error al cargar disponibilidad.',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
                SizedBox(height: 12),
                _botonRefrescar(),
              ],
            );
          }

          final data = snapshot.data!;
          int accesos = data['accesos_actuales'];
          int capacidadMaxima = data['capacidad_maxima'];
          double porcentaje = (accesos / capacidadMaxima) * 100;
          String horaSugerida = data['hora_sugerida'] ?? '';

          if (porcentaje < 10) porcentaje = 10;
          if (porcentaje > 90) porcentaje = 100;

          String mensaje;
          Color containerColor;

          if (porcentaje < 30) {
            mensaje = 'Muy buen momento entrenar';
            containerColor = AppColors.activeColor;
          } else if (porcentaje < 50) {
            mensaje = 'Buen momento para entrenar';
            containerColor = AppColors.blueColor;
          } else if (porcentaje < 70) {
            mensaje = 'Estamos un poco saturados';
            containerColor = AppColors.amaColor;
          } else if (porcentaje < 90) {
            mensaje = 'Gimnasio muy concurrido';
            containerColor = AppColors.orangeColor;
          } else {
            mensaje = 'No recomendable, gimnasio lleno';
            containerColor = AppColors.textColor;
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 5),
              Text(
                'Destacados',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: containerColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mensaje,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Espacio ocupado ${porcentaje.toStringAsFixed(0)}%',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {});
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: containerColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            minimumSize: Size(0, 0),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.refresh, size: 18),
                              SizedBox(width: 6),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (porcentaje >= 50 && horaSugerida.isNotEmpty) ...[
                      SizedBox(height: 4),
                      Builder(
                        builder: (context) {
                          String mensajeHora = '';
                          try {
                            final partes = horaSugerida.split(':');
                            final hora = int.parse(partes[0]);
                            final minuto = int.parse(partes[1]);
                            final ahora = TimeOfDay.now();

                            if (hora < 6) {
                              mensajeHora = 'Abrimos a las 06:00 am';
                            } else if (hora > 21 || (hora == 21 && minuto > 30)) {
                              mensajeHora = 'Recomendamos asistir mañana';
                            } else if (hora >= 21) {
                              mensajeHora = 'Cerramos hasta las 10:00 pm';
                            } else {
                              final esPm = hora >= 12;
                              int hora12 = hora % 12 == 0 ? 12 : hora % 12;
                              final sufijo = esPm ? 'pm' : 'am';
                              mensajeHora = 'Horario sugerido: ${hora12.toString().padLeft(2, '0')}:${partes[1]} $sufijo';
                            }
                          } catch (e) {
                            mensajeHora = 'Horario sugerido no disponible';
                          }

                          return Text(
                            mensajeHora,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ],
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
              case 3:
                Navigator.pushNamed(context, '/membresia');
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

