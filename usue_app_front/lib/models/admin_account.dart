class AdminAccount {
  final String id;
  final String login;
  final String email;
  final DateTime createdAt;
  final bool superAdmin;

  const AdminAccount({
    required this.id,
    required this.login,
    required this.email,
    required this.createdAt,
    this.superAdmin = false,
  });

  AdminAccount copyWith({
    String? login,
    String? email,
    bool? superAdmin,
  }) =>
      AdminAccount(
        id: id,
        login: login ?? this.login,
        email: email ?? this.email,
        createdAt: createdAt,
        superAdmin: superAdmin ?? this.superAdmin,
      );
}
