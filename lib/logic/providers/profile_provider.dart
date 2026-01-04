import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

// --- Models ---

class Address {
  final String id;
  final String label; // e.g., Home, Work
  final String fullName;
  final String street;
  final String city;
  final String state;
  final String zipCode;
  final String phoneNumber;

  Address({
    required this.id,
    required this.label,
    required this.fullName,
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.phoneNumber,
  });

  Address copyWith({
    String? label,
    String? fullName,
    String? street,
    String? city,
    String? state,
    String? zipCode,
    String? phoneNumber,
  }) {
    return Address(
      id: id,
      label: label ?? this.label,
      fullName: fullName ?? this.fullName,
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}

class PaymentMethod {
  final String id;
  final String cardHolderName;
  final String cardNumber; // Showing last 4 digits only in UI usually, but storing for demo
  final String expiryDate; // MM/YY
  final String cvv;
  final String cardType; // e.g., Visa, Mastercard

  PaymentMethod({
    required this.id,
    required this.cardHolderName,
    required this.cardNumber,
    required this.expiryDate,
    required this.cvv,
    required this.cardType,
  });
}

// --- State ---

class ProfileState {
  final List<Address> addresses;
  final List<PaymentMethod> paymentMethods;

  ProfileState({
    this.addresses = const [],
    this.paymentMethods = const [],
  });

  ProfileState copyWith({
    List<Address>? addresses,
    List<PaymentMethod>? paymentMethods,
  }) {
    return ProfileState(
      addresses: addresses ?? this.addresses,
      paymentMethods: paymentMethods ?? this.paymentMethods,
    );
  }
}

// --- Notifier ---

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier() : super(ProfileState(
    addresses: [
      Address(
        id: Uuid().v4(),
        label: 'Home',
        fullName: 'Alex Doe',
        street: '123 Main Street, Apt 4B',
        city: 'New York',
        state: 'NY',
        zipCode: '10001',
        phoneNumber: '555-0123',
      )
    ],
    paymentMethods: [
       PaymentMethod(
        id: Uuid().v4(),
        cardHolderName: 'Alex Doe',
        cardNumber: '4242 4242 4242 4242',
        expiryDate: '12/26',
        cvv: '123',
        cardType: 'VISA',
      ),
    ]
  ));

  // Address Actions
  void addAddress(Address address) {
    state = state.copyWith(addresses: [...state.addresses, address]);
  }

  void updateAddress(Address updatedAddress) {
    state = state.copyWith(
      addresses: state.addresses.map((a) => a.id == updatedAddress.id ? updatedAddress : a).toList(),
    );
  }

  void deleteAddress(String id) {
    state = state.copyWith(
      addresses: state.addresses.where((a) => a.id != id).toList(),
    );
  }

  // Payment Method Actions
  void addPaymentMethod(PaymentMethod method) {
    state = state.copyWith(paymentMethods: [...state.paymentMethods, method]);
  }

  void deletePaymentMethod(String id) {
    state = state.copyWith(
      paymentMethods: state.paymentMethods.where((p) => p.id != id).toList(),
    );
  }
}

// --- Provider ---

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier();
});
