class BatchStatistics {
  final String batchId;
  final String batchName;
  final int totalChicks;
  final int deathsCount;
  final int soldCount;
  final int remainingCount;
  final double totalBuyPrice;
  final double totalAdditionsCost;
  final double totalSalesAmount;
  final double profitLoss;
  final double actualCostPerChick;

  BatchStatistics({
    required this.batchId,
    required this.batchName,
    required this.totalChicks,
    required this.deathsCount,
    required this.soldCount,
    required this.remainingCount,
    required this.totalBuyPrice,
    required this.totalAdditionsCost,
    required this.totalSalesAmount,
    required this.profitLoss,
    required this.actualCostPerChick,
  });

  // الحسابات التلقائية
  double get totalCost => totalBuyPrice + totalAdditionsCost;
  double get expectedProfit =>
      (remainingCount * 0) + totalSalesAmount - totalCost; // سيتم تحديثه لاحقاً
}
