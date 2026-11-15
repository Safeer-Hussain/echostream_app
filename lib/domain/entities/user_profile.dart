class UserProfile {
  final String name;
  final String handle;
  final String email;
  final String avatarAsset;
  final String audioHardwareTier;
  final double weeklyHoursListened;
  final int totalTracksCompleted;
  final int offlineVaultCount;
  final double offlineVaultMb;

  const UserProfile({
    required this.name,
    required this.handle,
    required this.email,
    required this.avatarAsset,
    required this.audioHardwareTier,
    required this.weeklyHoursListened,
    required this.totalTracksCompleted,
    required this.offlineVaultCount,
    required this.offlineVaultMb,
  });

  UserProfile copyWith({
    String? name,
    String? handle,
    String? email,
    String? avatarAsset,
    String? audioHardwareTier,
    double? weeklyHoursListened,
    int? totalTracksCompleted,
    int? offlineVaultCount,
    double? offlineVaultMb,
  }) {
    return UserProfile(
      name: name ?? this.name,
      handle: handle ?? this.handle,
      email: email ?? this.email,
      avatarAsset: avatarAsset ?? this.avatarAsset,
      audioHardwareTier: audioHardwareTier ?? this.audioHardwareTier,
      weeklyHoursListened: weeklyHoursListened ?? this.weeklyHoursListened,
      totalTracksCompleted: totalTracksCompleted ?? this.totalTracksCompleted,
      offlineVaultCount: offlineVaultCount ?? this.offlineVaultCount,
      offlineVaultMb: offlineVaultMb ?? this.offlineVaultMb,
    );
  }
}
