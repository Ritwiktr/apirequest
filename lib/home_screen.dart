import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'models.dart';
import 'user_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final userService = Provider.of<UserService>(context);
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('User Request', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, color: Colors.white),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: Container(
        height: size.height,
        width: size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue[700]!, Colors.purple[500]!],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + padding.bottom),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    SizedBox(height: size.height * 0.02),
                    buildInputField(_userIdController, 'User ID', Icons.person),
                    SizedBox(height: size.height * 0.02),
                    buildInputField(_idController, 'Request ID', Icons.request_page),
                    SizedBox(height: size.height * 0.04),
                    buildFetchButton(userService),
                    SizedBox(height: size.height * 0.04),
                    buildResultWidget(userService, size),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildInputField(TextEditingController controller, String label, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white70),
          prefixIcon: Icon(icon, color: Colors.white70),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.2),
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a valid $label';
          }
          if (int.tryParse(value) == null) {
            return 'Please enter a valid number';
          }
          return null;
        },
      ),
    ).animate().fade(duration: 500.ms).slideY(begin: 0.2, end: 0);
  }

  Widget buildFetchButton(UserService userService) {
    return ElevatedButton(
      onPressed: () => _fetchUserRequest(userService),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'Fetch User Request',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue[700],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 5,
      ),
    ).animate().scale(duration: 300.ms, curve: Curves.easeInOut);
  }

  Widget buildResultWidget(UserService userService, Size size) {
    if (userService.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ).animate().fade();
    } else if (userService.error != null) {
      return _buildErrorWidget(userService.error!);
    } else if (userService.userRequest != null) {
      return _buildUserRequestWidget(userService.userRequest!, size);
    }
    return SizedBox.shrink();
  }

  Widget _buildErrorWidget(String error) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red[300]!, width: 2),
      ),
      child: Text(
        error,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    ).animate().fade(duration: 500.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildUserRequestWidget(UserRequest request, Size size) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white.withOpacity(0.9),
      child: Container(
        width: size.width,
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildAnimatedText('Title', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.blue[900])),
            SizedBox(height: 8),
            _buildAnimatedText(request.title ?? "N/A", style: TextStyle(fontSize: 20, color: Colors.black87)),
            SizedBox(height: 20),
            _buildAnimatedText('Body', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.blue[900])),
            SizedBox(height: 8),
            _buildAnimatedText(request.body ?? "N/A", style: TextStyle(fontSize: 20, color: Colors.black87)),
          ],
        ),
      ),
    ).animate().fade(duration: 500.ms).scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1));
  }

  Widget _buildAnimatedText(String text, {TextStyle? style}) {
    return Text(
      text,
      style: style,
    ).animate().fade(duration: 300.ms).slideY(begin: 0.2, end: 0);
  }

  void _fetchUserRequest(UserService userService) async {
    if (_formKey.currentState!.validate()) {
      final userId = int.parse(_userIdController.text);
      final id = int.parse(_idController.text);
      await userService.fetchUserRequest(userId, id);
    }
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('About User Request App'),
          content: Text('This app allows you to fetch and view user requests. '
              'Enter a User ID and Request ID to fetch the corresponding request.'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white.withOpacity(0.9),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}