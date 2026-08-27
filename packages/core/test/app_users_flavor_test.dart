// AppUsers menentukan tab Work Order & Vehicle muncul atau tidak
// (lihat bottom_nav_bar.dart). Nilainya ditulis di .env DENGAN tanda kutip
// (VITE_APP_USERS="Teknisi"), jadi yang diuji di sini terutama: kutipnya
// benar-benar dilepas flutter_dotenv, bukan ikut jadi bagian nilai.
import 'package:bitrack_core/base/services/app_users.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('nilai berkutip "Teknisi" dikenali sebagai build teknisi', () {
    dotenv.testLoad(fileInput: 'VITE_APP_USERS="Teknisi"');
    expect(AppUsers.value, 'Teknisi', reason: 'tanda kutip harus dilepas');
    expect(AppUsers.isTechnicianApp, isTrue);
  });

  test('nilai berkutip "Customer" menyembunyikan tab', () {
    dotenv.testLoad(fileInput: 'VITE_APP_USERS="Customer"');
    expect(AppUsers.value, 'Customer');
    expect(AppUsers.isTechnicianApp, isFalse);
  });

  test('key tidak ada -> bukan build teknisi (tab tersembunyi)', () {
    dotenv.testLoad(fileInput: 'BASE_URL="https://example.test/api"');
    expect(AppUsers.isTechnicianApp, isFalse);
  });
}
