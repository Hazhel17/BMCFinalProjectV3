import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Used for date formatting [cite: 79]

class AdminOrderScreen extends StatefulWidget {
  const AdminOrderScreen({super.key});

  @override
  State<AdminOrderScreen> createState() => _AdminOrderScreenState();
}

class _AdminOrderScreenState extends State<AdminOrderScreen> {
  // 1. Get an instance of Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 2. Function to update the status in Firestore [cite: 90]
  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    try {
      // 3. Find the document and update the 'status' field [cite: 93]
      await _firestore.collection('orders').doc(orderId).update({
        'status': newStatus,
      });
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order status updated!')), //[cite: 98]
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $e')), //[cite: 102]
      );
    }
  }

  // 4. Function to show the update status dialog [cite: 105]
  void _showStatusDialog(String orderId, String currentStatus) {
    showDialog(
      context: context,
      builder: (context) {
        // 5. A list of all possible statuses [cite: 111]
        const statuses = ['Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled'];

        return AlertDialog(
          title: const Text('Update Order Status'), //[cite: 113]
          content: Column(
          mainAxisSize: MainAxisSize.min, // Make the dialog small [cite: 115]
          children: statuses.map((status) {
            // 6. Create a ListTile for each status [cite: 117]
            return ListTile(
              title: Text(status),
              // 7. Show a checkmark next to the current status [cite: 120]
              trailing: currentStatus == status ? const Icon(Icons.check) : null,
              onTap: () {
                // 8. When tapped:
                _updateOrderStatus(orderId, status); // Call update [cite: 123]
                Navigator.of(context).pop(); // Close the dialog [cite: 124]
              },
            );
          }).toList(),
        ),
        actions: [
        TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Close'),
        ),
        ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Manage Orders'), //[cite: 152]
      ),
      // 1. Use a StreamBuilder to get all orders [cite: 153]
      body: StreamBuilder<QuerySnapshot>(
        // 2. This is our query
          stream: _firestore
              .collection('orders') //[cite: 157]
          .orderBy('createdAt', descending: true) // Newest first [cite: 158]
          .snapshots(),
      builder: (context, snapshot) {
        // 3. Handle all states: loading, error, empty [cite: 160]
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator()); //[cite: 163]
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}')); //[cite: 166]
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No orders found.')); //[cite: 167]
        }

        // 4. We have the orders!
        final orders = snapshot.data!.docs; //[cite: 169]

        return ListView.builder(
            itemCount: orders.length, //[cite: 171]
            itemBuilder: (context, index) {
          final order = orders[index];
          final orderData = order.data() as Map<String, dynamic>; //[cite: 174]

          // 5. Format the date
          final Timestamp timestamp = orderData['createdAt']; //[cite: 176]
          final String formattedDate = DateFormat('MM/dd/yyyy hh:mm a')
              .format(timestamp.toDate()); //[cite: 177]

          // 6. Get the current status
          final String status = orderData['status']; //[cite: 179]

          // 7. Build a Card for each order
          return Card(
              margin: const EdgeInsets.all(8.0), //[cite: 182]
              child: ListTile(
          title: Text(
          'Order ID: ${order.id}', // Show the doc ID [cite: 186]
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), //[cite: 187]
          ),
        subtitle: Text(
        'User: ${orderData['userId']}\n' +
        'Total: P${(orderData['totalPrice']).toStringAsFixed(2)} | Date: $formattedDate', //[cite: 189, 191]
        ),
        isThreeLine: true, //[cite: 192]

        // 8. Show the status with a colored chip [cite: 193]
        trailing: Chip(
        label: Text(
        status, //[cite: 196]
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold), //[cite: 197, 198]
        ),
        backgroundColor: // Ternary operator to set color [cite: 226]
        status == 'Pending' ? Colors.orange: //[cite: 203]
        status == 'Processing' ? Colors.blue: //[cite: 204]
        status == 'Shipped' ? Colors.deepPurple: //[cite: 205]
        status == 'Delivered' ? Colors.green: Colors.red, //[cite: 206]
        ),

        // 9. On tap, show our update dialog [cite: 208, 228]
        onTap: () {
        _showStatusDialog(order.id, status); //[cite: 213]
        },
        ),
        );
        },
        );
        },
    ),
    );
  }
}