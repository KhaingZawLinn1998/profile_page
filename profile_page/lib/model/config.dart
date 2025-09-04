class Config {
  final bool readOnlyPhoneNo;
  final bool readOnlyDob;
  final bool readOnlyGender;

  const Config(
      {this.readOnlyPhoneNo = false,
      this.readOnlyDob = true,
      this.readOnlyGender = false});
}
