/// Model for batch attendance data (batch name + attendance rate)
class BatchAttendance {
  final int batchId;
  final String batchName;
  final String timing;
  final double attendanceRate;

  BatchAttendance({
    required this.batchId,
    required this.batchName,
    required this.timing,
    required this.attendanceRate,
  });

  @override
  String toString() {
    return 'BatchAttendance(batchId: $batchId, batchName: $batchName, attendanceRate: $attendanceRate%)';
  }
}
