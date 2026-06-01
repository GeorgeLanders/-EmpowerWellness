enum WorldState {
  seed,        // Level 0: Just a glowing seed
  sprout,      // Level 1: A small crystalline plant
  tree,        // Level 2: A fully grown glowing tree
  garden,      // Level 3: A cluster of fantasy plants
  empire      // Level 4: A floating glass city
}

class DioramaController {
  static String getWorldImageAsset(WorldState state) {
    switch (state) {
      case WorldState.seed:
        return 'assets/diorama/world_seed.png';
      case WorldState.sprout:
        return 'assets/diorama/world_sprout.png';
      case WorldState.tree:
        return 'assets/diorama/world_tree.png';
      case WorldState.garden:
        return 'assets/diorama/world_garden.png';
      case WorldState.empire:
        return 'assets/diorama/world_empire.png';
    }
  }

  static WorldState calculateState(int currentProgress) {
    if (currentProgress < 20) return WorldState.seed;
    if (currentProgress < 40) return WorldState.sprout;
    if (currentProgress < 60) return WorldState.tree;
    if (currentProgress < 80) return WorldState.garden;
    return WorldState.empire;
  }
}
