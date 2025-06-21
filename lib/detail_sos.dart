import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'sos_screen.dart';

class GoogleMapsStyleBottomSheet extends StatefulWidget {
  final EmergencyLocation location;

  const GoogleMapsStyleBottomSheet({super.key, required this.location});

  @override
  State<GoogleMapsStyleBottomSheet> createState() => _GoogleMapsStyleBottomSheetState();
}

class _GoogleMapsStyleBottomSheetState extends State<GoogleMapsStyleBottomSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['Ringkasan', 'Menu', 'Ulasan', 'Foto', 'Info Terkait'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.2,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 8),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    
                    // Header with place name and actions
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.location.name,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "${widget.location.category}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.volume_up_outlined),
                                onPressed: () {},
                              ),
                              IconButton(
                                icon: const Icon(Icons.share_outlined),
                                onPressed: () {},
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Rating and review info
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Text(
                            widget.location.rating.toString(),
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 4),
                          RatingStars(rating: widget.location.rating),
                          const SizedBox(width: 4),
                          Text(
                            "(${widget.location.reviews})",
                            style: TextStyle(color: Colors.grey[700], fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    
          
                    
                    // Open status
                    if (widget.location.openUntil != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                        child: Row(
                          children: [
                            Text(
                              "Tutup",
                              style: TextStyle(color: Colors.red[700], fontSize: 14),
                            ),
                            Text(
                              " • ${widget.location.openUntil}",
                              style: TextStyle(color: Colors.grey[800], fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      
                    // Special note
                    if (widget.location.specialNote != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                        child: Text(
                          widget.location.specialNote!,
                          style: TextStyle(color: Colors.orange[800], fontSize: 14),
                        ),
                      ),
                      
                    // Action buttons
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          _buildActionButton(Icons.phone, "Telepon", Colors.blue),
                      
                        ],
                      ),
                    ),
                    
                    const Divider(height: 16),
                  ],
                ),
              ),
              
              // Tab bar
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelColor: Colors.teal,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.teal,
                    indicatorWeight: 3,
                    tabs: _tabs.map((String tab) => Tab(text: tab)).toList(),
                  ),
                ),
                pinned: true,
              ),
              
              // Tab content
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Ringkasan tab
                    _buildSummaryTab(),
                    
                    // Menu tab
                    _buildMenuTab(),
                    
                    // Ulasan tab
                    _buildReviewsTab(),
                    
                    // Foto tab
                    _buildPhotosTab(),
                    
                    // Info Terkait tab
                    _buildInfoTab(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton.icon(
        onPressed: () {
          if (label == "Telepon") {
            _launchPhoneCall(widget.location.phoneNumber);
          }
        },
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[50],
          foregroundColor: color,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary section
        Text(
          "Ringkasan ulasan",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
        
        // Rating visual
        Row(
          children: [
            Text(
              widget.location.rating.toString(),
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRatingBar(5, 0.8),
                  _buildRatingBar(4, 0.15),
                  _buildRatingBar(3, 0.03),
                  _buildRatingBar(2, 0.01),
                  _buildRatingBar(1, 0.01),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 20),
        
        // Tags
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var tag in widget.location.tags)
              _buildTag(tag, widget.location.tags.indexOf(tag) + 3),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Reviews preview
        if (widget.location.reviewsList.isNotEmpty) ...[
          ...widget.location.reviewsList.map((review) => _buildReviewItem(review)).toList(),
          
          const SizedBox(height: 16),
          
          // Add review button
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black87,
              side: BorderSide(color: Colors.grey[300]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Text("Beri rating dan ulas"),
          ),
        ],
        
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildRatingBar(int starCount, double percentage) {
    return Row(
      children: [
        SizedBox(
          width: 10, 
          child: Text(
            "$starCount",
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Container(
            height: 8,
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.grey[200],
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.amber,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTag(String tag, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        "$tag $count",
        style: TextStyle(fontSize: 14, color: Colors.grey[800]),
      ),
    );
  }

  Widget _buildReviewItem(Review review) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: review.author == "C" ? Colors.red : Colors.teal,
            radius: 16,
            child: Text(
              review.author.substring(0, 1),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '"${review.comment}"',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.arrow_forward, size: 16, color: Colors.grey[600]),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTab() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          "Informasi Layanan Darurat",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildReviewsTab() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          "Ulasan Pengguna",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildPhotosTab() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          "Galeri Foto",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildInfoTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Address section
          const Text(
            "Alamat",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on, color: Colors.grey[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.location.address,
                      style: TextStyle(color: Colors.grey[800]),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.volume_up_outlined, size: 20, color: Colors.grey[700]),
                        const SizedBox(width: 16),
                        Icon(Icons.keyboard_arrow_down, color: Colors.grey[700]),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          
          // Hours section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.access_time, color: Colors.grey[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Jam Operasional",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.location.openUntil ?? "Buka 24 jam",
                      style: TextStyle(color: Colors.red[700]),
                    ),
                    if (widget.location.specialNote != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.location.specialNote!,
                        style: TextStyle(color: Colors.orange[800], fontSize: 14),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.keyboard_arrow_down, color: Colors.grey[700]),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

 Future<void> _launchPhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri.parse('tel:$phoneNumber');
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Tidak dapat membuka telepon")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
    // Tidak perlu mengembalikan nilai karena tipe return adalah Future<void>
  }
}

class RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  
  const RatingStars({
    Key? key,
    required this.rating,
    this.size = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return Icon(Icons.star, size: size, color: Colors.amber);
        } else if (index == rating.floor() && rating % 1 > 0) {
          return Icon(Icons.star_half, size: size, color: Colors.amber);
        } else {
          return Icon(Icons.star_border, size: size, color: Colors.amber);
        }
      }),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverAppBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false; // Mengimplementasikan method yang sebelumnya kurang
  }
}