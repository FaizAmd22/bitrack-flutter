/// Huruf pertama tiap kata jadi kapital, mis. `"truk box"` -> `"Truk Box"`.
/// Spasi ganda dirapatkan. Huruf lain tidak diubah.
String titleCase(String s) {
  return s
      .split(' ')
      .where((w) => w.isNotEmpty)
      .map((w) => w[0].toUpperCase() + w.substring(1))
      .join(' ');
}
