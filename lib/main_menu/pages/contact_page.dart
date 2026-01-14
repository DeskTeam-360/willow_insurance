import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import '../../services/data_service.dart';
import '../../models/data_init_model.dart';
import 'webview_page.dart';
import '../../utils/log_util.dart';

class ContactPage extends StatefulWidget {
  final int? initialTabIndex;
  
  // Static variable to store the tab index to open
  static int? _pendingTabIndex;
  
  static void setInitialTab(int tabIndex) {
    _pendingTabIndex = tabIndex;
  }
  
  ContactPage({super.key, this.initialTabIndex});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _commentsController = TextEditingController();
  String _bookAnAppointment = 'Rose';
  bool _isSubmitting = false;

  final List<String> _appointmentOptions = [
    'Natalie',
    'Kristen',
    'Jason',
    'Rose',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Set initial tab if provided or from static variable
    _checkAndSetTab();
  }

  void _checkAndSetTab() {
    int? tabToOpen = widget.initialTabIndex ?? ContactPage._pendingTabIndex;
    if (tabToOpen != null && tabToOpen < 2) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _tabController.index != tabToOpen) {
          _tabController.animateTo(tabToOpen);
          // Clear the pending tab index after using it
          ContactPage._pendingTabIndex = null;
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check again in case the tab was set after initState
    _checkAndSetTab();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  Future<String> _getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return 'DEV-${androidInfo.id}'; // ANDROID_ID
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return 'DEV-${iosInfo.identifierForVendor ?? "unknown"}';
      }
    } catch (e) {
      debugPrint('Error getting device ID: $e');
      return 'DEV-error';
    }
    return 'DEV-unknown';
  }

  bool _validateEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> _submitContactForm() async {
    // Validation
    if (_firstNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('First name is required')));
      return;
    }

    if (_lastNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Last name is required')));
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Email is required')));
      return;
    }

    if (!_validateEmail(_emailController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }

    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Phone is required')));
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final deviceId = await _getDeviceId();
      final apiUrl =
          'https://willowinsurance.ca/wp-json/gf-custom/v1/form4';

      final body = json.encode({
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'comments': _commentsController.text.trim(),
        'book_an_appoinment': _bookAnAppointment,
        'device_id': deviceId,
      });

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        if (response.statusCode == 200 || response.statusCode == 201) {
          // Success - clear form
          _firstNameController.clear();
          _lastNameController.clear();
          _emailController.clear();
          _phoneController.clear();
          _commentsController.clear();
          setState(() {
            _bookAnAppointment = 'Rose';
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Contact form submitted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          debugPrint(
            'Failed to submit contact form: ${response.statusCode} - ${response.body}',
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to submit form. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error submitting contact form: $e');
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting form: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.35,
              child: SvgPicture.asset(
                'assets/images/willow_splashscreen.svg',
                width: MediaQuery.of(context).size.width * 2,
                fit: BoxFit.cover,
                alignment: Alignment.bottomCenter,
              ),
            ),
          ),
          Column(
            children: [
              SizedBox(height: 50),
              // Logo
              Center(
                child: Image.asset(
                  'assets/images/willow_logo.png',
                  height: 60,
                  fit: BoxFit.fitWidth,
                ),
              ),
              SizedBox(height: 20),
              // Title "Contact"
              // Center(
              //   child: Text(
              //     'Contact Willow Insurance Corp.',
              //     style: TextStyle(
              //       color: Color(0xFF497844),
              //       fontSize: 24,
              //       fontWeight: FontWeight.bold,
              //     ),
              //   ),
              // ),
              SizedBox(height: 20),
              // TabBar
              Container(
                margin: EdgeInsets.symmetric(horizontal: 30.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: Color(0xFF497844),
                  labelColor: Color(0xFF497844),
                  unselectedLabelColor: Colors.grey[600],
                  labelStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                  tabs: [
                    Tab(text: 'Contact Us'),
                    Tab(text: 'Booking'),
                  ],
                ),
              ),
              // SizedBox(height: 20),
              // TabBarView
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: Contact Us Form
                    _buildContactUsTab(),
                    // Tab 2: Book Appointment
                    _buildBookAppointmentTab(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactUsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: 30.0,
        // vertical: 20.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                      SizedBox(height: 20),
                      // General Inquiry section
                      Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'General Inquiry',
                              style: TextStyle(
                                color: Color(0xFF497844),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  color: Color(0xFF3E3E3E),
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Shell Lake',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(text: ': 306.427.2255\n'),
                                  TextSpan(
                                    text: 'Debden',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(text: ': 306.724.2012'),
                                ],
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'We want to hear from you. We appreciate your comments and welcome any suggestions or questions you may have concerning our products, services, or website.',
                              style: TextStyle(
                                color: Color(0xFF3E3E3E),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      // Form fields container
                      Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Color(0xFFffffff),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // First Name field
                            TextField(
                              controller: _firstNameController,
                              decoration: InputDecoration(
                                labelText: 'First Name',
                                floatingLabelAlignment: FloatingLabelAlignment.start,
                                floatingLabelStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  height: 2,
                                ),
                                labelStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  height: 1.5,
                                ),
                                prefixIcon: Icon(
                                  Icons.person,
                                  color: Color(0xFF497844),
                                  size: 20,
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF0F0F0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Color(0xffe0e0e0), width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xffe0e0e0), width: 1),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xffe0e0e0), width: 1),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 12,
                                ),
                              ),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 15),
                            // Last Name field
                            TextField(
                              controller: _lastNameController,
                              decoration: InputDecoration(
                                labelText: 'Last Name',
                                floatingLabelAlignment: FloatingLabelAlignment.start,
                                floatingLabelStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  height: 2,
                                ),
                                labelStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  height: 1.5,
                                ),
                                prefixIcon: Icon(
                                  Icons.badge,
                                  color: Color(0xFF497844),
                                  size: 20,
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF0F0F0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Color(0xffe0e0e0), width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xffe0e0e0), width: 1),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xffe0e0e0), width: 1),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 12,
                                ),
                              ),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 15),
                            // Email field
                            TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                floatingLabelAlignment: FloatingLabelAlignment.start,
                                floatingLabelStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  height: 2,
                                ),
                                labelStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  height: 1.5,
                                ),
                                prefixIcon: Icon(
                                  Icons.email,
                                  color: Color(0xFF497844),
                                  size: 20,
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF0F0F0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Color(0xffe0e0e0), width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xffe0e0e0), width: 1),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xffe0e0e0), width: 1),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 12,
                                ),
                              ),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 15),
                            // Phone field
                            TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: 'Phone',
                                floatingLabelAlignment: FloatingLabelAlignment.start,
                                floatingLabelStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  height: 2,
                                ),
                                labelStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  height: 1.5,
                                ),
                                prefixIcon: Icon(
                                  Icons.phone,
                                  color: Color(0xFF497844),
                                  size: 20,
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF0F0F0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Color(0xffe0e0e0), width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xffe0e0e0), width: 1),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xffe0e0e0), width: 1),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 12,
                                ),
                              ),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 15),
                            // Book an Appointment field
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0F0F0),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Color(0xffe0e0e0),
                                  width: 1,
                                ),
                              ),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Agent',
                                  floatingLabelAlignment: FloatingLabelAlignment.start,
                                  floatingLabelStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    height: 2,
                                  ),
                                  labelStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    height: 1.5,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.calendar_today,
                                    color: Color(0xFF497844),
                                    size: 20,
                                  ),
                                  filled: true,
                                  fillColor: Colors.transparent,
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 12,
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _bookAnAppointment,
                                    isExpanded: true,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.black,
                                    ),
                                    items: _appointmentOptions.map((
                                      String option,
                                    ) {
                                      return DropdownMenuItem<String>(
                                        value: option,
                                        child: Text(
                                          option,
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      if (newValue != null) {
                                        setState(() {
                                          _bookAnAppointment = newValue;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 15),
                            // Comments field
                            TextField(
                              controller: _commentsController,
                              decoration: InputDecoration(
                                labelText: 'Comments',
                                floatingLabelAlignment: FloatingLabelAlignment.start,
                                floatingLabelStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  height: 2,
                                ),
                                labelStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  height: 1.5,
                                ),
                                prefixIcon: Icon(
                                  Icons.comment,
                                  color: Color(0xFF497844),
                                  size: 20,
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF0F0F0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Color(0xffe0e0e0), width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xffe0e0e0), width: 1),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xffe0e0e0), width: 1),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 12,
                                ),
                              ),
                              maxLines: 4,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      // Submit button
                      ElevatedButton(
                        onPressed: _isSubmitting
                            ? null
                            : _submitContactForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF497844),
                          padding: EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: Size(double.infinity, 20),
                        ),
                        child: _isSubmitting
                            ? SizedBox(
                                height: 15,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                'Submit',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                      SizedBox(height: 100),
                    ],
                  ),
    );
  }

  Widget _buildBookAppointmentTab() {
    return BookAppointmentTabContent();
  }
}

// Book Appointment Tab Content Widget
class BookAppointmentTabContent extends StatefulWidget {
  @override
  State<BookAppointmentTabContent> createState() => _BookAppointmentTabContentState();
}

class _BookAppointmentTabContentState extends State<BookAppointmentTabContent> {
  bool _isLoading = false;
  List<BookAppointment> _allAppointments = [];
  
  String? _selectedCategory; // Notary, Auto, Farm, Home, Commercial
  String? _selectedPolicyType; // New Policy or Policy Review (only for non-Notary)
  String? _selectedLocation;
  BookAppointment? _selectedAppointment;
  
  List<String> _availableCategories = [];
  List<String> _availablePolicyTypes = ['Policy Review', 'New Policy']; // Order: Policy Review, New Policy
  List<String> _availableLocations = [];

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    final dataService = DataService();
    
    if (dataService.isDataLoaded) {
      _updateAppointments(dataService.cachedData);
    } else {
      setState(() {
        _isLoading = true;
      });
      
      try {
        final data = await dataService.fetchData();
        _updateAppointments(data);
      } catch (e) {
        debugPrint('Error loading appointments: $e');
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _updateAppointments(DataInit? data) {
    if (data != null) {
      if (mounted) {
        setState(() {
          _allAppointments = data.bookAppointment;
          
          // Extract unique categories from typeOfInsurance
          // If contains " - ", take the part before " - "
          // If doesn't contain " - ", use the whole string
          Set<String> categories = {};
          for (var apt in _allAppointments) {
            if (apt.typeOfInsurance.isNotEmpty) {
              if (apt.typeOfInsurance.contains(' - ')) {
                String category = apt.typeOfInsurance.split(' - ')[0].trim();
                categories.add(category);
              } else {
                categories.add(apt.typeOfInsurance);
              }
            }
          }
          // Sort categories: Home, Commercial, Farm, Auto, Notary, then others
          List<String> categoryOrder = ['Home', 'Commercial', 'Farm', 'Auto', 'Notary'];
          _availableCategories = categories.toList();
          _availableCategories.sort((a, b) {
            int indexA = categoryOrder.indexOf(a);
            int indexB = categoryOrder.indexOf(b);
            
            // If both are in the order list, sort by their position
            if (indexA != -1 && indexB != -1) {
              return indexA.compareTo(indexB);
            }
            // If only A is in the order list, A comes first
            if (indexA != -1) return -1;
            // If only B is in the order list, B comes first
            if (indexB != -1) return 1;
            // If neither is in the order list, sort alphabetically
            return a.compareTo(b);
          });
        });
      }
    }
  }

  void _onCategoryChanged(String? value) {
    if (value == null) return;
    
    setState(() {
      _selectedCategory = value;
      _selectedPolicyType = null;
      _selectedLocation = null;
      _selectedAppointment = null;
      
      // Update available locations based on category
      _updateAvailableLocations();
      
      // If Notary, don't auto-select appointment, wait for location
    });
  }

  void _onPolicyTypeChanged(String? value) {
    if (value == null || _selectedCategory == null) return;
    
    setState(() {
      _selectedPolicyType = value;
      _selectedAppointment = null;
      
      // Don't reset location, just find appointment with current location
      if (_selectedLocation != null) {
        _findAndSetAppointment(_selectedCategory!, value, _selectedLocation);
      }
    });
  }

  void _onLocationChanged(String? value) {
    if (value == null || _selectedCategory == null) return;
    
    setState(() {
      _selectedLocation = value;
      
      // For Notary, find appointment directly after location is selected
      if (_selectedCategory == 'Notary') {
        _findAndSetAppointment(_selectedCategory!, null, value);
      }
      // For others, wait for policy type to be selected
      else if (_selectedPolicyType != null) {
        _findAndSetAppointment(_selectedCategory!, _selectedPolicyType, value);
      }
    });
  }

  void _updateAvailableLocations() {
    if (_selectedCategory == null) {
      _availableLocations = [];
      return;
    }
    
    Set<String> locations = {};
    
    for (var apt in _allAppointments) {
      String aptCategory;
      
      if (apt.typeOfInsurance.contains(' - ')) {
        List<String> parts = apt.typeOfInsurance.split(' - ');
        aptCategory = parts[0].trim();
      } else {
        aptCategory = apt.typeOfInsurance;
      }
      
      // Show all locations for the selected category
      if (aptCategory == _selectedCategory && apt.location.isNotEmpty) {
        locations.add(apt.location);
      }
    }
    
    // Sort locations: Shell Lake, Debden, Online, then others
    List<String> locationOrder = ['Shell Lake', 'Debden', 'Online'];
    _availableLocations = locations.toList();
    _availableLocations.sort((a, b) {
      int indexA = locationOrder.indexOf(a);
      int indexB = locationOrder.indexOf(b);
      
      // If both are in the order list, sort by their position
      if (indexA != -1 && indexB != -1) {
        return indexA.compareTo(indexB);
      }
      // If only A is in the order list, A comes first
      if (indexA != -1) return -1;
      // If only B is in the order list, B comes first
      if (indexB != -1) return 1;
      // If neither is in the order list, sort alphabetically
      return a.compareTo(b);
    });
  }

  void _findAndSetAppointment(String category, String? policyType, String? location) {
    // Find matching appointment
    BookAppointment? foundAppointment;
    
    for (var apt in _allAppointments) {
      String aptCategory;
      String aptPolicyType;
      
      if (apt.typeOfInsurance.contains(' - ')) {
        List<String> parts = apt.typeOfInsurance.split(' - ');
        aptCategory = parts[0].trim();
        aptPolicyType = parts.length > 1 ? parts[1].trim() : '';
      } else {
        aptCategory = apt.typeOfInsurance;
        aptPolicyType = '';
      }
      
      // Check category match
      bool categoryMatches = aptCategory == category;
      
      // Check policy type match
      bool policyTypeMatches = true;
      if (category != 'Notary' && policyType != null) {
        if (policyType == 'New Policy') {
          policyTypeMatches = aptPolicyType.contains('New Policy');
        } else if (policyType == 'Policy Review') {
          policyTypeMatches = aptPolicyType == 'Policy Review';
        }
      } else if (category == 'Notary') {
        policyTypeMatches = true;
      }
      
      // Check location match
      bool locationMatches = location == null || apt.location == location;
      
      if (categoryMatches && policyTypeMatches && locationMatches) {
        foundAppointment = apt;
        break;
      }
    }
    
    if (foundAppointment != null) {
      setState(() {
        _selectedAppointment = foundAppointment;
      });
    }
  }

  Future<void> _openAppointmentLink() async {
    if (_selectedAppointment != null && _selectedAppointment!.appointmentLink.isNotEmpty) {
      final Uri url = Uri.parse(_selectedAppointment!.appointmentLink);
      
      try {
        if (await canLaunchUrl(url)) {
          await launchUrl(
            url,
            mode: LaunchMode.externalApplication,
          );
        } else {
          // Fallback to WebView if can't launch externally
          if (mounted) {
            await LogUtil.saveLog('Opening appointment link: ${_selectedAppointment!.appointmentLink}');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WebViewPage(
                  url: _selectedAppointment!.appointmentLink,
                  title: 'Book Appointment',
                ),
              ),
            );
          }
        }
      } catch (e) {
        // Fallback to WebView on error
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WebViewPage(
                url: _selectedAppointment!.appointmentLink,
                title: 'Book Appointment',
              ),
            ),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Appointment link is not available'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: 30.0,
        vertical: 20.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isLoading)
            Center(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: Column(
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF497844),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading appointments...',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Color(0xFFffffff),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category dropdown
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Color(0xffe0e0e0),
                        width: 1,
                      ),
                    ),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Insurance Type',
                        floatingLabelAlignment: FloatingLabelAlignment.start,
                        floatingLabelStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          height: 2,
                        ),
                        labelStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          height: 1.5,
                        ),
                        prefixIcon: Icon(
                          Icons.shield,
                          color: Color(0xFF497844),
                          size: 20,
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 12,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCategory,
                          isExpanded: true,
                          hint: Text(
                            'Select Category',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                          ),
                          items: _availableCategories.map((String option) {
                            return DropdownMenuItem<String>(
                              value: option,
                              child: Text(
                                option,
                                style: TextStyle(fontSize: 14),
                              ),
                            );
                          }).toList(),
                          onChanged: _onCategoryChanged,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  // Location dropdown
                  if (_selectedCategory != null && _availableLocations.isNotEmpty)
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Color(0xffe0e0e0),
                          width: 1,
                        ),
                      ),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Location',
                          floatingLabelAlignment: FloatingLabelAlignment.start,
                          floatingLabelStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            height: 2,
                          ),
                          labelStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            height: 1.5,
                          ),
                          prefixIcon: Icon(
                            Icons.location_on,
                            color: Color(0xFF497844),
                            size: 20,
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 12,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedLocation,
                            isExpanded: true,
                            hint: Text(
                              'Select Location',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              color: Colors.black,
                            ),
                            items: _availableLocations.map((String option) {
                              return DropdownMenuItem<String>(
                                value: option,
                                child: Text(
                                  option,
                                  style: TextStyle(fontSize: 14),
                                ),
                              );
                            }).toList(),
                            onChanged: _onLocationChanged,
                          ),
                        ),
                      ),
                    ),
                  if (_selectedLocation != null && _selectedCategory != null && _selectedCategory != 'Notary')
                    SizedBox(height: 15),
                  // Policy Type dropdown (only for non-Notary, after location is selected)
                  if (_selectedLocation != null && _selectedCategory != null && _selectedCategory != 'Notary')
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Color(0xffe0e0e0),
                          width: 1,
                        ),
                      ),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Policy Type',
                          floatingLabelAlignment: FloatingLabelAlignment.start,
                          floatingLabelStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            height: 2,
                          ),
                          labelStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            height: 1.5,
                          ),
                          prefixIcon: Icon(
                            Icons.description,
                            color: Color(0xFF497844),
                            size: 20,
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 12,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedPolicyType,
                            isExpanded: true,
                            hint: Text(
                              'Select Policy Type',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              color: Colors.black,
                            ),
                            items: _availablePolicyTypes.map((String option) {
                              return DropdownMenuItem<String>(
                                value: option,
                                child: Text(
                                  option,
                                  style: TextStyle(fontSize: 14),
                                ),
                              );
                            }).toList(),
                            onChanged: _onPolicyTypeChanged,
                          ),
                        ),
                      ),
                    ),
                  if ((_selectedCategory == 'Notary' && _selectedLocation != null) || 
                      (_selectedPolicyType != null && _selectedLocation != null && _selectedCategory != null)) 
                    SizedBox(height: 15),
                  // Display selected appointment details
                  if (_selectedAppointment != null)
                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Color(0xFF497844),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selected Appointment Details:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF497844),
                            ),
                          ),
                          SizedBox(height: 10),
                          _buildDetailRow('Insurance', _selectedAppointment!.typeOfInsurance),
                          if (_selectedAppointment!.agent.isNotEmpty)
                            _buildDetailRow('Agent', _selectedAppointment!.agent),
                          if (_selectedAppointment!.location.isNotEmpty)
                            _buildDetailRow('Location', _selectedAppointment!.location),
                          if (_selectedAppointment!.timeNeeded.isNotEmpty)
                            _buildDetailRow('Time Needed', _selectedAppointment!.timeNeeded + ' minutes'),
                          SizedBox(height: 15),
                          // Button to open appointment link in webview
                          if (_selectedAppointment!.appointmentLink.isNotEmpty)
                            ElevatedButton(
                              onPressed: _openAppointmentLink,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF497844),
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                minimumSize: Size(double.infinity, 50),
                              ),
                              child: Text(
                                'Book Appointment',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
