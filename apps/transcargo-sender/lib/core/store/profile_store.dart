import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight, app-wide profile cache backed by SharedPreferences.
///
/// In-memory mirror is exposed as [ValueNotifier]s so widgets can listen.
/// Avatar is kept in memory only (XFile path) — persisted as a file path.
class ProfileStore {
  ProfileStore._();
  static final ProfileStore instance = ProfileStore._();

  static const _kFullName = 'profile.fullName';
  static const _kEmail    = 'profile.email';
  static const _kBio      = 'profile.bio';
  static const _kAddress  = 'profile.address';
  static const _kAvatar   = 'profile.avatarPath';
  static const _kPhone    = 'profile.phone';

  final fullName = ValueNotifier<String>('');
  final phone    = ValueNotifier<String>('');
  final email    = ValueNotifier<String>('');
  final bio      = ValueNotifier<String>('');
  final address  = ValueNotifier<String>('');
  final avatar   = ValueNotifier<XFile?>(null);

  bool _loaded = false;

  Future<void> load() async {
    if (_loaded) return;
    final p = await SharedPreferences.getInstance();
    fullName.value = p.getString(_kFullName) ?? '';
    email.value    = p.getString(_kEmail)    ?? '';
    bio.value      = p.getString(_kBio)      ?? '';
    address.value  = p.getString(_kAddress)  ?? '';
    phone.value    = p.getString(_kPhone)    ?? '';
    final ap = p.getString(_kAvatar);
    if (ap != null && ap.isNotEmpty) avatar.value = XFile(ap);
    _loaded = true;
  }

  Future<void> save({
    String? fullName,
    String? email,
    String? bio,
    String? address,
    String? phone,
    XFile? avatar,
  }) async {
    final p = await SharedPreferences.getInstance();
    if (fullName != null) { this.fullName.value = fullName; await p.setString(_kFullName, fullName); }
    if (email    != null) { this.email.value    = email;    await p.setString(_kEmail,    email);    }
    if (bio      != null) { this.bio.value      = bio;      await p.setString(_kBio,      bio);      }
    if (address  != null) { this.address.value  = address;  await p.setString(_kAddress,  address);  }
    if (phone    != null) { this.phone.value    = phone;    await p.setString(_kPhone,    phone);    }
    if (avatar   != null) {
      this.avatar.value = avatar;
      await p.setString(_kAvatar, avatar.path);
    }
  }

  Future<void> clear() async {
    final p = await SharedPreferences.getInstance();
    for (final k in [_kFullName, _kEmail, _kBio, _kAddress, _kPhone, _kAvatar]) {
      await p.remove(k);
    }
    fullName.value = '';
    email.value = '';
    bio.value = '';
    address.value = '';
    phone.value = '';
    avatar.value = null;
  }
}
