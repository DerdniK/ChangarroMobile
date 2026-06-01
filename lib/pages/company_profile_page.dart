import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class CompanyProfilePage extends StatelessWidget {
  final Uri _instagramUrl = Uri.parse('https://www.instagram.com/elchangarrodesus?igsh=YW03NWxjNmE0N3Yz');

  Future<void> _launchInstagram() async {
    // abre la pagina en ig o en el navegador
    if (!await launchUrl(_instagramUrl, mode: LaunchMode.externalApplication)) {
      throw Exception('No se pudo abrir el enlace $_instagramUrl');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Negro Mate
      appBar: AppBar(
        title: const Text('PERFIL DE LA EMPRESA', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: const Color(0xFFFFB300), // Amarillo
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          // seccion principal con el logo y el nombre
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFB300), Color(0xFFFF5722)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Color(0xFF121212),
                    child: Icon(Icons.storefront_rounded, size: 50, color: Color(0xFFFFB300)),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'CHANGARRO DE SUS',
                    style: TextStyle(color: Color(0xFF121212), fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF121212).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '“Hacemos tus ideas realidad”',
                      style: TextStyle(color: Color(0xFF121212), fontSize: 14, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // seccion de quienes somos y que hacemos
                  const Text('NUESTRA FILOSOFÍA', style: TextStyle(color: Color(0xFFFFB300), fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(16)),
                    child: const Text(
                      'Nos centramos más que nada en la calidad del producto. Nuestro objetivo es que cada artículo que te lleves a casa sea porque realmente te encanta y conecta con tus pasiones.',
                      style: TextStyle(color: Colors.white, fontSize: 15, height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // las redes nomas instagram
                  const Text('SÍGUENOS EN REDES', style: TextStyle(color: Color(0xFFFFB300), fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFFF5722), // Naranja
                        child: FaIcon(FontAwesomeIcons.instagram, color: Colors.white, size: 20),
                      ),
                      title: const Text('@elchangarrodesus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      subtitle: const Text('¡Mira los nuevos drops de stickers y pines!', style: TextStyle(color: Colors.white54, fontSize: 13)),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 16),
                      
                      // aqui abre instagram
                      onTap: () async {
                        final Uri url = Uri.parse('https://www.instagram.com/elchangarrodesus?igsh=YW03NWxjNmE0N3Yz');
                        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                          debugPrint('No se pudo abrir el enlace: $url');
                        }
                      },
                      
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ubicaciones
                  const Text('DÓNDE ENCONTRARNOS', style: TextStyle(color: Color(0xFFFFB300), fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        _buildLocationTile('Plaza Esfera', 'Puntos y bazares itinerantes de fin de semana.'),
                        const Divider(color: Colors.white10, height: 1),
                        _buildLocationTile('Plaza Constituyentes', 'Módulos especiales de exhibición urbana.'),
                        const Divider(color: Colors.white10, height: 1),
                        _buildLocationTile('Plaza Portal', 'Visítanos en nuestras activaciones de temporada.'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Componente interno para construir las sucursales limpiamente
  Widget _buildLocationTile(String title, String subtitle) {
    return ListTile(
      leading: const Icon(Icons.location_on_rounded, color: Color(0xFFFFB300)),
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
    );
  }
}