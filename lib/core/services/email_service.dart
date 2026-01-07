import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../data/models/product_model.dart';
import 'package:flutter/foundation.dart';

import '../constants.dart';

class EmailService {
  // Configured in AppConstants for runtime/environment changes
  static const String _apiKey = AppConstants.resendApiKey; 
  
  static const String _apiUrl = 'https://api.resend.com/emails';

  static Future<bool> sendOrderConfirmation({
    required String recipientEmail, // The "to" address
    required String customerName,
    required List<ProductModel> items,
    required double totalAmount,
  }) async {
    try {
      final orderItemsHtml = items.map((item) => '''
        <tr>
          <td style="padding: 8px; border-bottom: 1px solid #ddd;">${item.title}</td>
          <td style="padding: 8px; border-bottom: 1px solid #ddd;">\$${item.price.toStringAsFixed(2)}</td>
        </tr>
      ''').join('');

      final body = {
        "from": "SwiftShop <onboarding@resend.dev>", // Default testing sender
        "to": [recipientEmail],
        "subject": "Order Confirmation - SwiftShop",
        "html": '''
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
            <h1 style="color: #333;">Thank you for your order, $customerName!</h1>
            <p>We have received your order and are processing it.</p>
            
            <h3>Order Summary</h3>
            <table style="width: 100%; border-collapse: collapse;">
              <thead>
                <tr style="background-color: #f8f8f8;">
                  <th style="padding: 8px; text-align: left;">Item</th>
                  <th style="padding: 8px; text-align: left;">Price</th>
                </tr>
              </thead>
              <tbody>
                $orderItemsHtml
              </tbody>
            </table>
            
            <div style="margin-top: 20px; text-align: right;">
              <h3>Total: \$${totalAmount.toStringAsFixed(2)}</h3>
            </div>
            
            <p style="color: #777; font-size: 12px; margin-top: 40px;">
              This is an automated message from SwiftShop.
            </p>
          </div>
        '''
      };

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Email sent successfully: ${response.body}');
        return true;
      } else {
        debugPrint('Failed to send email: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error sending email: $e');
      return false;
    }
  }
}
