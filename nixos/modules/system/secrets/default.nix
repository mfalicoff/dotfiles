{username, ...}:
{
  sops = {
    age.keyFile = "/home/${username}/.config/sops/age/keys.txt";

    secrets = {
      caddy = {
        sopsFile = ../../../secrets/secrets.caddy.yaml;
        restartUnits = [ "caddy.service" ];
      };
      miniflux = {
        sopsFile = ../../../secrets/secrets.miniflux.yaml;
        restartUnits = [ "miniflux.service" ];
      };
      karakeep-oauth2 = {
        sopsFile = ../../../secrets/secrets.karakeep.yaml;
        restartUnits = [
          "karakeep-workers.service"
          "karakeep-web.service"
          "karakeep-browsers.service"
        ];
      };
      smb = {
        sopsFile = ../../../secrets/secrets.smb.yaml;
      };
      strava = {
        sopsFile = ../../../secrets/secrets.strava.yaml;
        restartUnits = [ "podman-statistics-for-strava.service" ];
      };
    };
  };
}