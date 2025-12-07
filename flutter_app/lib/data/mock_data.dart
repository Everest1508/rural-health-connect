import '../models/doctor_model.dart';
import '../models/appointment_model.dart';

class MockData {
  // Mock doctors data - matching the React app
  static final List<Doctor> doctors = [
    Doctor(
      id: '1',
      name: 'Dr. Gurpreet Kaur',
      specialty: 'General Physician',
      rating: 4.8,
      experience: '12 years',
      available: true,
      fee: 200,
    ),
    Doctor(
      id: '2',
      name: 'Dr. Rajinder Sharma',
      specialty: 'Pediatrician',
      rating: 4.9,
      experience: '15 years',
      available: true,
      fee: 300,
    ),
    Doctor(
      id: '3',
      name: 'Dr. Manpreet Singh',
      specialty: 'Dermatologist',
      rating: 4.7,
      experience: '8 years',
      available: false,
      fee: 350,
    ),
  ];

  // Mock appointments data - matching the React app
  static final List<Appointment> appointments = [
    Appointment(
      id: '1',
      doctorName: 'Dr. Harpreet Singh',
      specialty: 'General Physician',
      date: 'Dec 5, 2025',
      rawDate: '2025-12-05',
      time: '2:30 PM',
      type: AppointmentType.video,
      status: AppointmentStatus.scheduled,
    ),
    Appointment(
      id: '2',
      doctorName: 'Dr. Gurpreet Kaur',
      specialty: 'Pediatrician',
      date: 'Dec 8, 2025',
      rawDate: '2025-12-08',
      time: '10:00 AM',
      type: AppointmentType.inPerson,
      status: AppointmentStatus.confirmed,
    ),
    Appointment(
      id: '3',
      doctorName: 'Dr. Rajinder Sharma',
      specialty: 'Cardiologist',
      date: 'Nov 28, 2025',
      rawDate: '2025-11-28',
      time: '4:00 PM',
      type: AppointmentType.video,
      status: AppointmentStatus.completed,
    ),
  ];

  // Health tips data
  static final List<Map<String, String>> healthTips = [
    {
      'title': 'Stay Hydrated',
      'description': 'Drink at least 8 glasses of water daily',
      'icon': '💧',
    },
    {
      'title': 'Regular Exercise',
      'description': '30 minutes of physical activity each day',
      'icon': '🏃',
    },
    {
      'title': 'Balanced Diet',
      'description': 'Include fruits and vegetables in every meal',
      'icon': '🥗',
    },
    {
      'title': 'Quality Sleep',
      'description': 'Get 7-8 hours of sleep every night',
      'icon': '😴',
    },
  ];

  // Quick actions data
  static final List<Map<String, dynamic>> quickActions = [
    {
      'label': 'Video Consult',
      'description': 'Talk to a doctor now',
      'icon': 'video',
      'gradient': true,
      'gradientType': 'primary',
    },
    {
      'label': 'Symptom Check',
      'description': 'AI-powered diagnosis',
      'icon': 'activity',
      'gradient': true,
      'gradientType': 'accent',
    },
    {
      'label': 'Find Medicine',
      'description': 'Check availability nearby',
      'icon': 'pill',
      'color': 'success',
    },
    {
      'label': 'Nearby Pharmacy',
      'description': 'Find pharmacies',
      'icon': 'map-pin',
      'color': 'warning',
    },
  ];
}
