import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/routes/app_routes.dart';

class InquiriesPage extends StatefulWidget {
  const InquiriesPage({Key? key}) : super(key: key);

  @override
  State<InquiriesPage> createState() => _InquiriesPageState();
}

class _InquiriesPageState extends State<InquiriesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<InquiryItem> _inquiries = [
    InquiryItem(
      id: 'i1',
      propertyTitle: 'Premium Glass Penthouse',
      area: 'Gulshan 2',
      date: 'July 6, 2026',
      offeredPrice: 120000,
      status: InquiryStatus.pending,
      message: 'Hello, is this penthouse available for visit this Friday morning?',
    ),
    InquiryItem(
      id: 'i2',
      propertyTitle: 'Modern Skyline Studio',
      area: 'Banani',
      date: 'July 4, 2026',
      offeredPrice: 60000,
      status: InquiryStatus.responded,
      message: 'I can pay 60k upfront. Will that be fine?',
    ),
    InquiryItem(
      id: 'i3',
      propertyTitle: 'Spacious Family Duplex',
      area: 'Dhanmondi',
      date: 'June 28, 2026',
      offeredPrice: 85000,
      status: InquiryStatus.responded,
      message: 'Is parking included in the rent?',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Inquiries Tracker'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Responded'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInquiriesList(_inquiries),
          _buildInquiriesList(_inquiries.where((i) => i.status == InquiryStatus.pending).toList()),
          _buildInquiriesList(_inquiries.where((i) => i.status == InquiryStatus.responded).toList()),
        ],
      ),
    );
  }

  Widget _buildInquiriesList(List<InquiryItem> list) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_turned_in_outlined, size: 48, color: AppColors.textLight),
            const SizedBox(height: 12),
            Text('No inquiries found.', style: AppTextStyles.bodyMedium),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final inquiry = list[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.lowest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.low, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.01),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header line: title and badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      inquiry.propertyTitle,
                      style: AppTextStyles.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusBadge(inquiry.status),
                ],
              ),
              const SizedBox(height: 6),
              Text('${inquiry.area} • Sent on ${inquiry.date}', style: AppTextStyles.bodySmall),
              const SizedBox(height: 14),

              // Quote message
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.low,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '"${inquiry.message}"',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textPrimary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Offer detail and action button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '৳${inquiry.offeredPrice.toInt().toString()}/mo',
                        style: AppTextStyles.priceSmall,
                      ),
                      const Text(
                        'Offered Rent',
                        style: TextStyle(color: AppColors.textLight, fontSize: 10),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.directChat);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Open Chat',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(InquiryStatus status) {
    final isPending = status == InquiryStatus.pending;
    final color = isPending ? AppColors.secondary : AppColors.success;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        isPending ? 'Pending' : 'Responded',
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

enum InquiryStatus { pending, responded }

class InquiryItem {
  final String id;
  final String propertyTitle;
  final String area;
  final String date;
  final double offeredPrice;
  final InquiryStatus status;
  final String message;

  InquiryItem({
    required this.id,
    required this.propertyTitle,
    required this.area,
    required this.date,
    required this.offeredPrice,
    required this.status,
    required this.message,
  });
}
