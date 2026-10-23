{...}: {
  # Aerofi needs a running user service to handle its global launcher hotkey.
  homebrew.brews = [
    {
      name = "frostymur/tap/aerofi";
      start_service = true;
      restart_service = "changed";
    }
  ];
}
