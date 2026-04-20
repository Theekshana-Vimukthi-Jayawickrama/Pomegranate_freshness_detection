import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../ai/pipeline_predictor.dart';
import '../ai/gemini_client.dart';
import '../ai/pomegranate_assistant.dart';
import '../ui/pomegranate_chat_panel.dart';
import 'about_us_screen.dart';
import 'contact_us_screen.dart';
import 'privacy_policy_screen.dart';

class PipelineTestPage extends StatefulWidget {
  const PipelineTestPage({super.key});

  @override
  State<PipelineTestPage> createState() => _PipelineTestPageState();
}

class _PipelineTestPageState extends State<PipelineTestPage>
    with SingleTickerProviderStateMixin {
  final picker = ImagePicker();
  final pipeline = PomegranatePipeline();

  Uint8List? imageBytes;
  PipelineResult? result;

  bool loading = true;
  String status = "Loading models...";

  late final GeminiClient gemini;
  late final PomegranateAssistant assistant;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Pomegranate color scheme
  static const pomegranateRed = Color(0xFFC73E1D);
  static const pomegranateDeep = Color(0xFF8B2635);
  static const pomegranatePink = Color(0xFFE8959C);
  static const pomegranateLight = Color(0xFFFFF5F5);
  static const pomegranateSeed = Color(0xFFB8434D);
  static const pomegranateGreen = Color(0xFF4A7C59);

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    const apiKey = String.fromEnvironment('GEMINI_API_KEY');
    gemini = GeminiClient(apiKey: apiKey, modelName: "gemini-2.5-flash");
    assistant = PomegranateAssistant(gemini: gemini);

    _init();
  }

  Future<void> _init() async {
    try {
      await pipeline.load();
      setState(() {
        loading = false;
        status = "✅ Ready. Pick an image.";
      });
      _animationController.forward();
    } catch (e, st) {
      // Surface load error to the user and stop the loading state.
      // Include stack trace in logs and truncate for UI display.
      // ignore: avoid_print
      print('Pipeline init failed: $e\n$st');

      final msg = e?.toString() ?? 'Unknown error';
      final trace = st?.toString() ?? '';
      final short = trace.split('\n').take(3).join(' | ');

      setState(() {
        loading = false;
        status = "❌ Failed to load models: $msg";
      });

      // Also show a snackbar if scaffold is available
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final s = ScaffoldMessenger.of(context);
          s.showSnackBar(SnackBar(content: Text('Model load error: $msg')));
        }
      });
    }
  }

  // ✅ Request permission based on source
  Future<bool> _requestPermission(ImageSource source) async {
    late Permission permission;
    String permissionType = '';
    
    if (source == ImageSource.camera) {
      permission = Permission.camera;
      permissionType = 'Camera';
    } else {
      permission = Permission.storage;
      permissionType = 'Photo Library';
    }

    // ignore: avoid_print
    print('Requesting $permissionType permission');

    // Request permission
    final status = await permission.request();
    
    // ignore: avoid_print
    print('$permissionType permission status: $status');

    if (status.isGranted) {
      // ignore: avoid_print
      print('$permissionType permission granted');
      return true;
    }

    if (status.isDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$permissionType permission is required'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      // ignore: avoid_print
      print('$permissionType permission denied');
      return false;
    }

    if (status.isPermanentlyDenied) {
      if (mounted) {
        _showPermissionDialog(source, permissionType);
      }
      // ignore: avoid_print
      print('$permissionType permission permanently denied');
      return false;
    }

    return false;
  }

  // ✅ Show dialog for permanent permission denial
  void _showPermissionDialog(ImageSource source, String permissionType) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Permission Required'),
        content: Text(
          '$permissionType permission is permanently denied. Please enable it in app settings to use this feature.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              openAppSettings();
              Navigator.pop(context);
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  // ✅ NEW: One function for BOTH camera + gallery
  Future<void> pickAndRun(ImageSource source) async {
    // Request permission first
    final hasPermission = await _requestPermission(source);
    if (!hasPermission) return;

    final x = await picker.pickImage(
      source: source,
      imageQuality: 100,
      preferredCameraDevice: CameraDevice.rear,
    );
    if (x == null) return;

    final b = await x.readAsBytes();

    setState(() {
      imageBytes = b;
      result = null;
      status = "Running pipeline...";
      loading = true;
    });

    _animationController.reset();

    final r = await pipeline.run(b);

    setState(() {
      result = r;
      status = r.message;
      loading = false;
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    pipeline.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = result;

    return Scaffold(
      backgroundColor: pomegranateLight,
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [pomegranateRed, pomegranateSeed],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.agriculture, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              "PomeScan",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.agriculture, color: Colors.white, size: 24),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: const Color(0xFFC73E1D),
              ),
              child: const Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About Us'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutUsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Contact Us'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ContactUsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Privacy Policy'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Status Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: loading
                    ? [Colors.orange, Colors.deepOrange]
                    : [pomegranateGreen, const Color(0xFF3A6B4A)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: (loading ? Colors.orange : pomegranateGreen).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                if (loading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                else
                  const Icon(Icons.check_circle, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    status,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // ✅ NEW: Two buttons (Camera + Gallery)
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Row(
                      children: [
                        Expanded(
                          child: _actionButton(
                            icon: Icons.photo_camera,
                            title: "Camera",
                            subtitle: "Take photo & analyze",
                            onTap: loading ? null : () => pickAndRun(ImageSource.camera),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _actionButton(
                            icon: Icons.photo_library,
                            title: "Gallery",
                            subtitle: "Pick image & analyze",
                            onTap: loading ? null : () => pickAndRun(ImageSource.gallery),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 300.0),
                    AnimatedOpacity(
                      opacity: 1.0,
                      duration: Duration(seconds: 2),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          'Tip: Use clear close-up images of the full pomegranate. Try taking or uploading images from different angles and sides after rotating the pomegranate, so you can get a more reliable overall result for that pomegranate. Avoid partial images for better accuracy.',
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontSize: 15.0,
                            color: Colors.black54,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  if (loading)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: pomegranateRed.withOpacity(0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            width: 60,
                            height: 60,
                            child: CircularProgressIndicator(
                              strokeWidth: 4,
                              valueColor: const AlwaysStoppedAnimation<Color>(pomegranateRed),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Analyzing pomegranate...",
                            style: TextStyle(
                              color: pomegranateDeep,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            backgroundColor: pomegranatePink.withOpacity(0.2),
                            valueColor: const AlwaysStoppedAnimation<Color>(pomegranateRed),
                            minHeight: 4,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),

                  if (imageBytes != null)
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: pomegranateRed.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Stack(
                            children: [
                              Image.memory(
                                imageBytes!,
                                height: 280,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(Icons.image, color: Colors.white, size: 16),
                                      SizedBox(width: 6),
                                      Text(
                                        "Selected Image",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  if (r != null)
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          if (r.f != null)
                            _buildResultCard(
                              icon: Icons.eco,
                              title: "Freshness Check",
                              value: r.f!.label == "fresh" ? "🌿 Fresh" : "🍂 Not Fresh",
                              subtitle:
                              "Fresh: ${r.f!.freshProb.toStringAsFixed(4)} | Non-fresh: ${r.f!.nonFreshProb.toStringAsFixed(4)}",
                              gradient: r.f!.label == "fresh"
                                  ? [const Color(0xFF43A047), const Color(0xFF2E7D32)]
                                  : [const Color(0xFFE65100), const Color(0xFFBF360C)],
                            ),

                          const SizedBox(height: 16),

                          PomegranateChatPanel(
                            pipelineResult: r,
                            assistant: assistant,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ NEW: reusable action button
  Widget _actionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [pomegranateRed, pomegranateSeed],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: pomegranateRed.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, size: 34, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard({
    required IconData icon,
    required String title,
    required String value,
    String? subtitle,
    required List<Color> gradient,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        value,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class AnimatedUsageTip extends StatefulWidget {
  const AnimatedUsageTip({super.key});

  @override
  State<AnimatedUsageTip> createState() => _AnimatedUsageTipState();
}

class _AnimatedUsageTipState extends State<AnimatedUsageTip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: const Offset(0, 0),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.98,
      end: 1.0,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const pomegranateRed = Color(0xFFC73E1D);
    const pomegranateLight = Color(0xFFFFF5F5);
    const pomegranateSeed = Color(0xFFB8434D);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  pomegranateLight,
                  Colors.white,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: pomegranateRed.withOpacity(0.18),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: pomegranateSeed.withOpacity(0.10),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: pomegranateRed.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.tips_and_updates_rounded,
                    color: pomegranateRed,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Usage Tip',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: pomegranateRed,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Use clear close-up images of the full pomegranate. Try taking or uploading images from different angles and sides after rotating the pomegranate, so you can get a more reliable overall result for that pomegranate. Avoid partial images for better accuracy.',
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          fontSize: 14.5,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}