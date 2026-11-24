/// Prize tiers, best first. Stored by name: never rename a value.
enum PrizeTier { top, high, mid, low }

/// What a ticket of the casino's deck is. Stored by name.
enum TicketKind {
  /// Pays money from the pool into an envelope.
  prize,

  /// Gives the draw back.
  refund,
}

/// The ways to draw from a week's deck; they all draw from the same one.
/// Stored by name.
enum CasinoGame { slots, grid, scratch, chest }
