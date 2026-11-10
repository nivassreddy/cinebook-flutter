import 'package:flutter/material.dart';

void main() => runApp(const CineBookApp());

// Single-file Movie Ticket Booking UI. Uses only Flutter SDK widgets.

class CineBookApp extends StatefulWidget {
  const CineBookApp({super.key});
  @override
  State<CineBookApp> createState() => _CineBookAppState();
}

class _CineBookAppState extends State<CineBookApp> {
  bool dark = false;
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'CineBook',
        debugShowCheckedModeBanner: false,
        themeMode: dark ? ThemeMode.dark : ThemeMode.light,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7054D8)),
          scaffoldBackgroundColor: const Color(0xFFF6F5FA),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF9C87F5),
            brightness: Brightness.dark,
          ),
        ),
        home: CineBookHome(
          dark: dark,
          onTheme: () => setState(() => dark = !dark),
        ),
      );
}

class Movie {
  final String title, genre, duration, rating, language, description;
  final Color color;
  final IconData icon;
  const Movie(this.title, this.genre, this.duration, this.rating,
      this.language, this.description, this.color, this.icon);
}

const movieList = <Movie>[
  Movie('The Last Galaxy', 'Sci-Fi • Adventur', '2h 18m', '8.7', 'English',
      'A team of explorers travels beyond the known galaxy to discover a mysterious world.',
      Color(0xFF273B80), Icons.rocket_launch),
  Movie('City of Dreams', 'Drama • Romance', '2h 05m', '8.2', 'Telugu',
      'Two strangers follow their dreams in a busy city and discover an unexpected friendship.',
      Color(0xFF9A4269), Icons.location_city),
  Movie('Shadow Mission', 'Action • Thriller', '2h 12m', '9.0', 'Hindi',
      'An undercover agent races against time to stop a dangerous plan.',
      Color(0xFF3D4C45), Icons.security),
  Movie('Laugh Out Loud', 'Comedy • Family', '1h 48m', '7.9', 'Tamil',
      'A hilarious family adventure full of surprises and unforgettable moments.',
      Color(0xFFB46A25), Icons.sentiment_very_satisfied),
  Movie('Ocean Mystery', 'Mystery • Adventure', '2h 01m', '8.4', 'English',
      'A marine researcher investigates strange signals from the deepest ocean.',
      Color(0xFF176B78), Icons.waves),
  Movie('The Final Match', 'Sports • Drama', '2h 10m', '8.6', 'Telugu',
      'A young player gets one final chance to lead his team to victory.',
      Color(0xFF8B3E36), Icons.sports_cricket),
];

class TicketBooking {
  final Movie movie;
  final String time, name, phone;
  final List<String> seats;
  const TicketBooking(this.movie, this.time, this.name, this.phone, this.seats);
  int get total => seats.length * 180;
}

class CineBookHome extends StatefulWidget {
  final bool dark;
  final VoidCallback onTheme;
  const CineBookHome({super.key, required this.dark, required this.onTheme});
  @override
  State<CineBookHome> createState() => _CineBookHomeState();
}

class _CineBookHomeState extends State<CineBookHome> {
  int page = 0;
  final bookings = <TicketBooking>[];

  void confirm(TicketBooking booking) {
    setState(() {
      bookings.insert(0, booking);
      page = 1;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Movie tickets booked successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.of(context).size.width >= 850;
    final screens = [
      MoviesScreen(onSelect: openMovie),
      BookingsScreen(bookings: bookings),
      ProfileScreen(dark: widget.dark, onTheme: widget.onTheme,
          count: bookings.length),
    ];
    const destinations = [
      NavigationDestination(icon: Icon(Icons.movie_outlined),
          selectedIcon: Icon(Icons.movie), label: 'Movies'),
      NavigationDestination(icon: Icon(Icons.confirmation_number_outlined),
          selectedIcon: Icon(Icons.confirmation_number), label: 'Bookings'),
      NavigationDestination(icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person), label: 'Profile'),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Row(children: [
          Icon(Icons.local_movies, color: Color(0xFF7054D8)),
          SizedBox(width: 9),
          Text('CineBook', style: TextStyle(fontWeight: FontWeight.bold)),
        ]),
        actions: [
          IconButton(
            tooltip: 'Toggle theme',
            onPressed: widget.onTheme,
            icon: Icon(widget.dark ? Icons.light_mode : Icons.dark_mode),
          ),
        ],
      ),
      body: Row(children: [
        if (desktop)
          NavigationRail(
            selectedIndex: page,
            onDestinationSelected: (i) => setState(() => page = i),
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.movie_outlined),
                  selectedIcon: Icon(Icons.movie), label: Text('Movies')),
              NavigationRailDestination(
                  icon: Icon(Icons.confirmation_number_outlined),
                  selectedIcon: Icon(Icons.confirmation_number),
                  label: Text('Bookings')),
              NavigationRailDestination(icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person), label: Text('Profile')),
            ],
          ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: KeyedSubtree(key: ValueKey(page), child: screens[page]),
          ),
        ),
      ]),
      bottomNavigationBar: desktop ? null : NavigationBar(
        selectedIndex: page,
        onDestinationSelected: (i) => setState(() => page = i),
        destinations: destinations,
      ),
    );
  }

  void openMovie(Movie movie) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => MovieDetailsScreen(
        movie: movie,
        onConfirm: (booking) {
          Navigator.pop(context);
          confirm(booking);
        },
      ),
    ));
  }
}

// MOVIE LIST: search, genre filters, GridView, cards and reusable poster.
class MoviesScreen extends StatefulWidget {
  final ValueChanged<Movie> onSelect;
  const MoviesScreen({super.key, required this.onSelect});
  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  String search = '', genre = 'All';
  final genres = const ['All', 'Action', 'Drama', 'Comedy', 'Adventure'];

  @override
  Widget build(BuildContext context) {
    final results = movieList.where((m) =>
        m.title.toLowerCase().contains(search.toLowerCase()) &&
        (genre == 'All' || m.genre.toLowerCase().contains(genre.toLowerCase()))
    ).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1150),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4934AA), Color(0xFF9B72E8)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(children: [
                const Positioned(right: 8, bottom: 0,
                    child: Icon(Icons.movie_filter, size: 95,
                        color: Colors.white24)),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Your next movie night starts here!',
                      style: TextStyle(color: Colors.white, fontSize: 23,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Discover movies. Choose seats. Enjoy the show.',
                      style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 15),
                  FilledButton(
                    style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF4934AA)),
                    onPressed: () => setState(() => genre = 'All'),
                    child: const Text('Explore Movies'),
                  ),
                ]),
              ]),
            ),
            const SizedBox(height: 24),
            const SectionHeading('Now Showing',
                'Choose a movie and book your favourite seats.'),
            const SizedBox(height: 14),
            TextField(
              onChanged: (v) => setState(() => search = v),
              decoration: InputDecoration(
                hintText: 'Search movies...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: genres.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => ChoiceChip(
                  label: Text(genres[i]),
                  selected: genre == genres[i],
                  onSelected: (_) => setState(() => genre = genres[i]),
                ),
              ),
            ),
            const SizedBox(height: 18),
            LayoutBuilder(builder: (context, constraints) {
              final cols = constraints.maxWidth >= 950 ? 4 :
                  constraints.maxWidth >= 650 ? 3 :
                  constraints.maxWidth >= 410 ? 2 : 1;
              if (results.isEmpty) {
                return const Center(child: Padding(
                  padding: EdgeInsets.all(30), child: Text('No movies found.')));
              }
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: results.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: cols == 1 ? 1.45 : 0.68,
                ),
                itemBuilder: (_, i) => MovieCard(
                  movie: results[i], onTap: () => widget.onSelect(results[i])),
              );
            }),
          ]),
        ),
      ),
    );
  }
}

class MovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;
  const MovieCard({super.key, required this.movie, required this.onTap});
  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(flex: 6, child: Hero(
          tag: movie.title, child: MoviePoster(movie: movie))),
        Expanded(flex: 4, child: Padding(
          padding: const EdgeInsets.all(11),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(movie.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 4),
            Text(movie.genre, maxLines: 1,
                style: Theme.of(context).textTheme.bodySmall),
            const Spacer(),
            Row(children: [
              const Icon(Icons.star, color: Colors.amber, size: 17),
              const SizedBox(width: 4),
              Text(movie.rating),
              const Spacer(),
              Text(movie.duration,
                  style: Theme.of(context).textTheme.bodySmall),
            ]),
            const SizedBox(height: 6),
            SizedBox(width: double.infinity,
              child: FilledButton(onPressed: onTap,
                  child: const Text('Book Tickets'))),
          ]),
        )),
      ]),
    ),
  );
}

class MoviePoster extends StatelessWidget {
  final Movie movie;
  const MoviePoster({super.key, required this.movie});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [movie.color, movie.color.withValues(alpha: 0.65)],
        begin: Alignment.topLeft, end: Alignment.bottomRight),
    ),
    child: Stack(alignment: Alignment.center, children: [
      Positioned(top: 10, right: 10,
        child: Chip(label: Text('★ ${movie.rating}',
            style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.black38)),
      Icon(movie.icon, size: 75, color: Colors.white.withValues(alpha: 0.9)),
      Positioned(bottom: 12, left: 8, right: 8,
        child: Text(movie.title.toUpperCase(), textAlign: TextAlign.center,
          maxLines: 2, style: const TextStyle(color: Colors.white,
            fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1))),
    ]),
  );
}

// DETAILS + SHOW TIME + SEAT SELECTION + VALIDATED CUSTOMER FORM.
class MovieDetailsScreen extends StatefulWidget {
  final Movie movie;
  final ValueChanged<TicketBooking> onConfirm;
  const MovieDetailsScreen({super.key, required this.movie, required this.onConfirm});
  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  final selectedSeats = <String>{};
  String showTime = '06:30 PM';
  final times = const ['10:00 AM', '01:30 PM', '06:30 PM', '09:45 PM'];
  final rows = const ['A', 'B', 'C', 'D', 'E'];
  bool booked(String seat) => ['A3', 'A4', 'B6', 'C2', 'D8'].contains(seat);

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Movie Details')),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 850),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(height: 205, width: double.infinity,
            child: Hero(tag: widget.movie.title,
              child: ClipRRect(borderRadius: BorderRadius.circular(18),
                child: MoviePoster(movie: widget.movie))),
          ),
          const SizedBox(height: 16),
          Text(widget.movie.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 5, children: [
            InfoChip(Icons.category, widget.movie.genre),
            InfoChip(Icons.schedule, widget.movie.duration),
            InfoChip(Icons.language, widget.movie.language),
            InfoChip(Icons.star, widget.movie.rating),
          ]),
          const SizedBox(height: 12),
          Text(widget.movie.description),
          const SizedBox(height: 22),
          const SectionHeading('Select Show Time', 'Choose a convenient show.'),
          const SizedBox(height: 12),
          Wrap(spacing: 8, children: times.map((t) => ChoiceChip(
            label: Text(t), selected: showTime == t,
            onSelected: (_) => setState(() => showTime = t),
          )).toList()),
          const SizedBox(height: 24),
          const SectionHeading('Select Your Seats',
              'Tap available seats to select or deselect.'),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(16)),
            child: Column(children: [
              Container(width: 230, height: 7,
                decoration: BoxDecoration(color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(20))),
              const SizedBox(height: 7),
              const Text('SCREEN', style: TextStyle(letterSpacing: 3,
                  fontWeight: FontWeight.bold, fontSize: 11)),
              const SizedBox(height: 18),
              ...rows.map((row) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  SizedBox(width: 20, child: Text(row)),
                  ...List.generate(8, (i) {
                    final seat = '$row${i + 1}';
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: SeatButton(
                        seat: seat, isBooked: booked(seat),
                        isSelected: selectedSeats.contains(seat),
                        onTap: () => setState(() {
                          if (selectedSeats.contains(seat)) {
                            selectedSeats.remove(seat);
                          } else {
                            selectedSeats.add(seat);
                          }
                        }),
                      ),
                    );
                  }),
                ]),
              )),
              const SizedBox(height: 12),
              const Wrap(alignment: WrapAlignment.center, spacing: 15, children: [
                SeatLegend(color: Color(0xFFB9B9C5), label: 'Available'),
                SeatLegend(color: Color(0xFF7657E8), label: 'Selected'),
                SeatLegend(color: Color(0xFFE36A6A), label: 'Booked'),
              ]),
            ]),
          ),
          const SizedBox(height: 18),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(15)),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${selectedSeats.length} seat(s) selected'),
                  Text('₹${selectedSeats.length * 180}',
                    style: const TextStyle(fontSize: 22,
                        fontWeight: FontWeight.bold)),
                ])),
              FilledButton.icon(
                onPressed: selectedSeats.isEmpty ? null : customerForm,
                icon: const Icon(Icons.confirmation_number),
                label: const Text('Continue'),
              ),
            ]),
          ),
        ]),
      )),
    ),
  );

  void customerForm() {
    final key = GlobalKey<FormState>();
    final name = TextEditingController();
    final phone = TextEditingController();
    showDialog(context: context, builder: (dialogContext) => AlertDialog(
      title: const Text('Booking Details'),
      content: Form(key: key, child: Column(mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(controller: name,
            decoration: const InputDecoration(labelText: 'Full Name',
                prefixIcon: Icon(Icons.person)),
            validator: (v) {
              if (v == null || v.trim().length < 3) return 'Enter your full name';
              return null;
            }),
          const SizedBox(height: 12),
          TextFormField(controller: phone, maxLength: 10,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: '10-digit Mobile Number',
                prefixIcon: Icon(Icons.phone)),
            validator: (v) {
              if (v == null || !RegExp(r'^[0-9]{10}$').hasMatch(v)) {
                return 'Enter a valid 10-digit number';
              }
              return null;
            }),
        ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel')),
        FilledButton(onPressed: () {
          if (key.currentState!.validate()) {
            final booking = TicketBooking(widget.movie, showTime,
                name.text.trim(), phone.text.trim(),
                selectedSeats.toList()..sort());
            Navigator.pop(dialogContext);
            widget.onConfirm(booking);
          }
        }, child: const Text('Confirm Booking')),
      ],
    ));
  }
}

class SeatButton extends StatelessWidget {
  final String seat;
  final bool isBooked, isSelected;
  final VoidCallback onTap;
  const SeatButton({super.key, required this.seat, required this.isBooked,
      required this.isSelected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final color = isBooked ? const Color(0xFFE36A6A) :
        isSelected ? const Color(0xFF7657E8) : const Color(0xFFB9B9C5);
    return Tooltip(message: '$seat',
      child: InkWell(
        onTap: isBooked ? null : onTap,
        borderRadius: BorderRadius.circular(6),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 27, height: 27, alignment: Alignment.center,
          decoration: BoxDecoration(color: color,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: isSelected ? Colors.white : Colors.transparent)),
          child: Text(seat.substring(1), style: const TextStyle(
              color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

class SeatLegend extends StatelessWidget {
  final Color color;
  final String label;
  const SeatLegend({super.key, required this.color, required this.label});
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min,
    children: [
      Container(width: 12, height: 12,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
      const SizedBox(width: 5),
      Text(label, style: const TextStyle(fontSize: 11)),
    ]);
}

// BOOKINGS SCREEN: ListView and ticket summary cards.
class BookingsScreen extends StatelessWidget {
  final List<TicketBooking> bookings;
  const BookingsScreen({super.key, required this.bookings});
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Center(child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 900),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SectionHeading('My Bookings', 'Your confirmed tickets appear here.'),
        const SizedBox(height: 18),
        if (bookings.isEmpty)
          Center(child: Padding(padding: const EdgeInsets.all(35),
            child: Column(children: [
              Icon(Icons.confirmation_number_outlined, size: 75,
                  color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 12),
              const Text('No bookings yet',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
              const Text('Book a movie to see your ticket here.'),
            ])))
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: bookings.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => BookingCard(booking: bookings[i]),
          ),
      ]),
    )),
  );
}

class BookingCard extends StatelessWidget {
  final TicketBooking booking;
  const BookingCard({super.key, required this.booking});
  @override
  Widget build(BuildContext context) => Card(
    child: Row(children: [
      Container(width: 8, height: 155, color: booking.movie.color),
      Expanded(child: Padding(padding: const EdgeInsets.all(15),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(booking.movie.title,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold))),
            const Icon(Icons.verified, color: Colors.green),
          ]),
          const SizedBox(height: 8),
          Text('Name: ${booking.name}'),
          Text('Show: ${booking.time}'),
          Text('Seats: ${booking.seats.join(", ")}'),
          const Divider(height: 18),
          Row(children: [
            const Text('Total Amount'), const Spacer(),
            Text('₹${booking.total}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ]),
        ]),
      )),
    ]),
  );
}

// PROFILE + THEME SETTINGS.
class ProfileScreen extends StatelessWidget {
  final bool dark;
  final VoidCallback onTheme;
  final int count;
  const ProfileScreen({super.key, required this.dark,
      required this.onTheme, required this.count});
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Center(child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 750),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SectionHeading('Profile & Settings',
            'Manage your CineBook application preferences.'),
        const SizedBox(height: 18),
        Card(child: const ListTile(
          leading: CircleAvatar(child: Icon(Icons.person)),
          title: Text('CineBook User',
              style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('Movie lover'),
        )),
        Card(child: SwitchListTile(
          secondary: Icon(dark ? Icons.dark_mode : Icons.light_mode),
          title: const Text('Dark Theme'),
          subtitle: const Text('Change application appearance'),
          value: dark, onChanged: (_) => onTheme(),
        )),
        Card(child: ListTile(
          leading: const Icon(Icons.confirmation_number),
          title: const Text('Total Bookings'),
          trailing: Text('$count'),
        )),
        const Card(child: ListTile(
          leading: Icon(Icons.info_outline),
          title: Text('About CineBook'),
          subtitle: Text('A sample Flutter movie ticket booking application.'),
        )),
        const Card(child: ListTile(
          leading: Icon(Icons.code),
          title: Text('Built with Flutter'),
          subtitle: Text('Dart • Material Design • StatefulWidget'),
        )),
      ]),
    )),
  );
}

// REUSABLE UI COMPONENTS.
class SectionHeading extends StatelessWidget {
  final String title, subtitle;
  const SectionHeading(this.title, this.subtitle, {super.key});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold)),
      const SizedBox(height: 5),
      Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant)),
    ],
  );
}

class InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const InfoChip(this.icon, this.label, {super.key});
  @override
  Widget build(BuildContext context) => Chip(
    avatar: Icon(icon, size: 16),
    label: Text(label),
    visualDensity: VisualDensity.compact,
  );
}
