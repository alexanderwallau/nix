{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.awallau.shairport-sync;
  configFile = pkgs.writeText "shairport-sync.conf" ''
    general =
    {
    name = "${cfg.name}";
    port = 7000; // Leave this for airplay2
    drift_tolerance_in_seconds = 0.002; 
    resync_threshold_in_seconds = 0.050; 
    default_airplay_volume = -28.0; // this is the suggested volume after a reset or after the high_volume_threshold has been exceed and the high_volume_idle_timeout_in_minutes has passed

    	high_threshold_airplay_volume = -16.0; // airplay volume greater or equal to this is "very loud"
     //	high_volume_idle_timeout_in_minutes = 30; // if the current volume is "very loud" and the device is not playing for more than this time, suggest the default volume for new connections instead of the current volume.
     //	dbus_service_bus = "system"; // The Shairport Sync dbus interface, if selected at compilation, will appear
     //		as "org.gnome.ShairportSync" on the whichever bus you specify here: "system" (default) or "session".
     //	mpris_service_bus = "system"; // The Shairport Sync mpris interface, if selected at compilation, will appear
     //		as "org.gnome.ShairportSync" on the whichever bus you specify here: "system" (default) or "session".
    };
     // Advanced parameters for controlling how Shairport Sync stays active and how it runs a session
     sessioncontrol =
    {
     //	"active" state starts when play begins and ends when the active_state_timeout has elapsed after play ends, unless another play session starts before the timeout has fully elapsed.
     //	run_this_before_entering_active_state = "/full/path/to/application and args"; // make sure the application has executable permission. If it's a script, include the shebang (#!/bin/...) on the first line
     //	run_this_after_exiting_active_state = "/full/path/to/application and args"; // make sure the application has executable permission. If it's a script, include the shebang (#!/bin/...) on the first line
     //	active_state_timeout = 10.0; // wait for this number of seconds after play ends before leaving the active state, unless another play session begins.

     //	run_this_before_play_begins = "/full/path/to/application and args"; // make sure the application has executable permission. If it's a script, include the shebang (#!/bin/...) on the first line
     //	run_this_after_play_ends = "/full/path/to/application and args"; // make sure the application has executable permission. If it's a script, include the shebang (#!/bin/...) on the first line

     //	run_this_if_an_unfixable_error_is_detected = "/full/path/to/application and args"; // if a problem occurs that can't be cleared by Shairport Sync itself, hook a program on here to deal with it.
     //	  An error code-string is passed as the last argument.
     //	  Many of these "unfixable" problems are caused by malfunctioning output devices, and sometimes it is necessary to restart the whole device to clear the problem.
     //	  You could hook on a program to do this automatically, but beware -- the device may then power off and restart without warning!
     //	wait_for_completion = "no"; // set to "yes" to get Shairport Sync to wait until the "run_this..." applications have terminated before continuing

     //	allow_session_interruption = "no"; // set to "yes" to allow another device to interrupt Shairport Sync while it's playing from an existing audio source
     //	session_timeout = 120; // wait for this number of seconds after a source disappears before terminating the session and becoming available again.
    };
    pa =
    {
    application_name = "Shairport Sync"; 
    };
     // --with-metadata, --with-dbus-interface, --with-mpris-interface or --with-mqtt-client.
     // In those cases, "enabled" and "include_cover_art" will both be "yes" by default
    metadata =
    {
     //	enabled = "yes"; // set this to yes to get Shairport Sync to solicit metadata from the source and to pass it on via a pipe
     //	include_cover_art = "yes"; // set to "yes" to get Shairport Sync to solicit cover art from the source and pass it via the pipe. You must also set "enabled" to "yes".
     //	cover_art_cache_directory = "/tmp/shairport-sync/.cache/coverart"; // artwork will be  stored in this directory if the dbus or MPRIS interfaces are enabled or if the MQTT client is in use. Set it to "" to prevent caching, which may be useful on some systems
     //	pipe_name = "/tmp/shairport-sync-metadata";
     //	pipe_timeout = 5000; // wait for this number of milliseconds for a blocked pipe to unblock before giving up
     //	progress_interval = 0.0; // if non-zero, progress 'phbt' messages will be sent at the interval specified in seconds. A 'phb0' message will also be sent when the first audio frame of a play session is about to be played.
     //		Each message consists of the RTPtime of a a frame of audio and the exact system time when it is to be played. The system time, in nanoseconds, is based the CLOCK_MONOTONIC_RAW of the machine -- if available -- or CLOCK_MONOTONIC otherwise.
     //		Messages are sent when the frame is placed in the output device's buffer, thus, they will be _approximately_ 'audio_backend_buffer_desired_length_in_seconds' (default 0.2 seconds) ahead of time.
     //	socket_address = "226.0.0.1"; // if set to a host name or IP address, UDP packets containing metadata will be sent to this address. May be a multicast address. "socket-port" must be non-zero and "enabled" must be set to yes"
     //	socket_port = 5555; // if socket_address is set, the port to send UDP packets to
     //	socket_msglength = 65000; // the maximum packet size for any UDP metadata. This will be clipped to be between 500 or 65000. The default is 500.
    };
  '';
in
{
  options.awallau.shairport-sync.enable = {
    enable = mkEnableOption "activate shairport";
    description = "Enable shairport-sync";

    name = mkOption {
      type = types.str;
      default = "Wohnzimmer";
      description = "Airplay advertised name";
    };
    # There a re a lot more option but changing those for most instances is not nessaary
  };
  config = lib.mkIf cfg.enable {
    services.shairport-sync = {
      enable = true;
      openFirewall = true;
      arguments = "-v -o pa -c ${configFile} --with-apple-alac";
    };

    users.users.shairport.extraGroups = [ "pulse-access" ];

    systemd.services.shairport-sync = {
      after = [ "pulseaudio.service" ];
      requires = [ "pulseaudio.service" ];
      serviceConfig = {
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
  };
}
