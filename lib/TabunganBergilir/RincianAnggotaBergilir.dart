import 'package:flutter/material.dart';

class RincianAnggotaBergilir extends StatelessWidget {
  const RincianAnggotaBergilir({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue.shade700, Colors.blue.shade400],
            ),
          ),
        ),
        elevation: 0,
        toolbarHeight: 84,
        titleSpacing: 16,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Rincian Anggota',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            height: 12,
            width: 12,
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Gudang Garam Jaya 🔥',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    textStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: Text('Undang'),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              '4 Anggota Bergabung',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: [
                  _buildMemberTile('ABI', '0123456789001', 'Pemilik',
                      'Membuat Goals pada 01 November 2024', Colors.blue),
                  _buildMemberTile('INTAN', '0123456789002', 'Anggota',
                      'Bergabung pada 01 November 2024', Colors.orange),
                  _buildMemberTile('UMI', '0123456789003', 'Anggota',
                      'Bergabung pada 02 November 2024', Colors.pink),
                  _buildMemberTile('EDI', '0123456789004', 'Anggota',
                      'Bergabung pada 03 November 2024', Colors.purple),
                  _buildMemberTile('OMEN', '0123456789005', 'Anggota',
                      'Bergabung pada 04 November 2024', Colors.deepOrange),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberTile(
      String name, String id, String role, String subtitle, Color color) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color,
        child: Text(
          name[0],
          style: TextStyle(color: Colors.white),
        ),
      ),
      title: Text(
        name,
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text('$id\n$subtitle'),
      trailing: Text(
        role,
        style: TextStyle(
          color: role == 'Pemilik' ? Colors.blue : Colors.orange,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
