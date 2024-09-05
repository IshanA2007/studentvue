class ZipCodeResult {
  String? districtName, districtUrl;

  ZipCodeResult({required this.districtName, required this.districtUrl});

  @override
  String toString() {
    return 'ZipCodeResult{districtName: $districtName, districtUrl: $districtUrl}';
  }
}
