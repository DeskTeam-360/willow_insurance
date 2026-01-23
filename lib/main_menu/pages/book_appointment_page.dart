import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../services/data_service.dart';
import '../../models/data_init_model.dart';
import 'webview_page.dart';

class BookAppointmentPage extends StatefulWidget {
  BookAppointmentPage({super.key});

  @override
  State<BookAppointmentPage> createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  bool _isLoading = false;
  List<BookAppointment> _allAppointments = [];
  
  String? _selectedTypeInsurance;
  String? _selectedAgent;
  String? _selectedAppointmentType;
  
  List<String> _availableTypeInsurances = [];
  List<String> _availableAgents = [];
  List<String> _availableAppointmentTypes = [];

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    final dataService = DataService();
    
    // Check if data is already cached
    if (dataService.isDataLoaded) {
      _updateAppointments(dataService.cachedData);
    } else {
      // Show loading and fetch data
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
          _availableTypeInsurances = _allAppointments
              .map((apt) => apt.typeOfInsurance)
              .where((type) => type.isNotEmpty)
              .toSet()
              .toList()
            ..sort();
        });
      }
    }
  }

  void _onTypeInsuranceChanged(String? value) {
    if (value == null) return;
    
    setState(() {
      _selectedTypeInsurance = value;
      _selectedAgent = null;
      _selectedAppointmentType = null;
      
      // Filter agents by selected insurance type
      _availableAgents = _allAppointments
          .where((apt) => apt.typeOfInsurance == value && apt.agent.isNotEmpty)
          .map((apt) => apt.agent)
          .toSet()
          .toList()
        ..sort();
      
      _availableAppointmentTypes = [];
    });
  }

  void _onAgentChanged(String? value) {
    if (value == null || _selectedTypeInsurance == null) return;
    
    setState(() {
      _selectedAgent = value;
      _selectedAppointmentType = null;
      
      // Filter appointment types by selected insurance type and agent
      _availableAppointmentTypes = _allAppointments
          .where((apt) => 
              apt.typeOfInsurance == _selectedTypeInsurance &&
              apt.agent == value &&
              apt.appointmentType.isNotEmpty)
          .map((apt) => apt.appointmentType)
          .toSet()
          .toList()
        ..sort();
    });
  }

  void _onAppointmentTypeChanged(String? value) {
    setState(() {
      _selectedAppointmentType = value;
    });
  }

  void _openAppointmentLink() {
    if (_selectedTypeInsurance != null &&
        _selectedAgent != null &&
        _selectedAppointmentType != null) {
      final appointment = _allAppointments.firstWhere(
        (apt) =>
            apt.typeOfInsurance == _selectedTypeInsurance &&
            apt.agent == _selectedAgent &&
            apt.appointmentType == _selectedAppointmentType,
      );
      
      if (appointment.appointmentLink.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WebViewPage(
              url: appointment.appointmentLink,
              title: 'Book Appointment',
            ),
          ),
        );
      } else {
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
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: Stack(
        children: [
          // Full height background
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
              // Header with back button (similar to video page)
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(30, 60, 30, 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(50.0),
                    bottomRight: Radius.circular(50.0),
                  ),
                  color: Color(0xFF71A33F),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: SvgPicture.asset(
                        'assets/images/back_button.svg',
                        width: 30,
                        height: 30,
                        colorFilter: ColorFilter.mode(
                          Color(0xFFffffff),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    Expanded(child: Container()),
                    Image.asset(
                      'assets/images/willow_logo_white.png',
                      height: 30,
                      fit: BoxFit.fitWidth,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 30.0,
                    vertical: 20.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      // Title
                      Center(
                        child: Text(
                          'Book an Appointment',
                          style: TextStyle(
                            color: Color(0xFF497844),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                SizedBox(height: 20),
                // Loading indicator
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
                        // Type Insurance dropdown
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
                              labelText: 'Insurance',
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
                                value: _selectedTypeInsurance,
                                isExpanded: true,
                                hint: Text(
                                  'Select Type Insurance',
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
                                items: _availableTypeInsurances.map((String option) {
                                  return DropdownMenuItem<String>(
                                    value: option,
                                    child: Text(
                                      option,
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  );
                                }).toList(),
                                onChanged: _onTypeInsuranceChanged,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                        // Agent dropdown (only shown when Type Insurance is selected)
                        if (_selectedTypeInsurance != null)
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
                                  Icons.person,
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
                                  value: _selectedAgent,
                                  isExpanded: true,
                                  hint: Text(
                                    'Select Agent',
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
                                  items: _availableAgents.map((String option) {
                                    return DropdownMenuItem<String>(
                                      value: option,
                                      child: Text(
                                        option,
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: _onAgentChanged,
                                ),
                              ),
                            ),
                          ),
                        if (_selectedTypeInsurance != null) SizedBox(height: 15),
                        // Appointment Type dropdown (only shown when Agent is selected)
                        if (_selectedAgent != null)
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
                                labelText: 'Appointment',
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
                                  value: _selectedAppointmentType,
                                  isExpanded: true,
                                  hint: Text(
                                    'Select Appointment Type',
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
                                  items: _availableAppointmentTypes.map((String option) {
                                    return DropdownMenuItem<String>(
                                      value: option,
                                      child: Text(
                                        option,
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: _onAppointmentTypeChanged,
                                ),
                              ),
                            ),
                          ),
                        if (_selectedAgent != null) SizedBox(height: 15),
                        // Display selected appointment details
                        if (_selectedAppointmentType != null)
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
                                _buildDetailRow('Type Insurance', _selectedTypeInsurance ?? ''),
                                _buildDetailRow('Agent', _selectedAgent ?? ''),
                                _buildDetailRow('Appointment Type', _selectedAppointmentType ?? ''),
                                if (_allAppointments.any((apt) => 
                                    apt.typeOfInsurance == _selectedTypeInsurance &&
                                    apt.agent == _selectedAgent &&
                                    apt.appointmentType == _selectedAppointmentType &&
                                    apt.location.isNotEmpty))
                                  _buildDetailRow(
                                    'Location',
                                    _allAppointments
                                        .firstWhere((apt) => 
                                            apt.typeOfInsurance == _selectedTypeInsurance &&
                                            apt.agent == _selectedAgent &&
                                            apt.appointmentType == _selectedAppointmentType)
                                        .location,
                                  ),
                                if (_allAppointments.any((apt) => 
                                    apt.typeOfInsurance == _selectedTypeInsurance &&
                                    apt.agent == _selectedAgent &&
                                    apt.appointmentType == _selectedAppointmentType &&
                                    apt.timeNeeded.isNotEmpty))
                                  _buildDetailRow(
                                    'Time Needed',
                                    _allAppointments
                                        .firstWhere((apt) => 
                                            apt.typeOfInsurance == _selectedTypeInsurance &&
                                            apt.agent == _selectedAgent &&
                                            apt.appointmentType == _selectedAppointmentType)
                                        .timeNeeded,
                                  ),
                                SizedBox(height: 15),
                                // Button to open appointment link in webview
                                if (_allAppointments.any((apt) => 
                                    apt.typeOfInsurance == _selectedTypeInsurance &&
                                    apt.agent == _selectedAgent &&
                                    apt.appointmentType == _selectedAppointmentType &&
                                    apt.appointmentLink.isNotEmpty))
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
                ),
              ),
            ],
          ),
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

