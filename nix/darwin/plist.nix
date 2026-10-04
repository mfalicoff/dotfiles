{
  programs.nix-plist-manager = {
    enable = true;
    options.applications = {
      finder = {
        settings.general.showTheseItemsOnTheDesktop = {
          hardDisks = true;
          externalDisks = true;
          connectedServers = true;
          cdsDvdsAndiPods = true;
        };
        settings.advanced = {
          showAllFilenameExtensions = true;
          showWarningBeforeChangingAnExtension = false;
          keepFoldersOnTop.inWindowsWhenSortingByName = true;
          whenPerformingASearch = "Search the Current Folder";
        };
        menuBar.view = {
          showPathBar = true;
          showStatusBar = true;
        };
      };

      systemSettings = {
        appearance.appearance = "Dark";

        desktopAndDock = {
          dock = {
            automaticallyHideAndShowTheDock.enabled = true;
            showSuggestedAndRecentAppsInDock = false;
          };
          desktopAndStageManager = {
            clickWallpaperToRevealDesktop = "Only in Stage Manager";
            showItems = {
              onDesktop = false;
              inStageManager = false;
            };
          };
          widgets.showWidgets = {
            onDesktop = true;
            inStageManager = true;
          };
          missionControl = {
            whenSwitchingToAnApplicationSwitchToAspaceWithOpenWindowsForTheApplication = true;
            displaysHaveSeparateSpaces = true;
          };
        };

        trackpad = {
          pointAndClick = {
            tapToClick = true;
            secondaryClick = "Click or Tap with Two Fingers";
          };
          scrollAndZoom.naturalScrolling = true;
        };

        keyboard = {
          keyRepeatRate = 3;
          delayUntilRepeat = 15;
          textInput = {
            capitalizeWordsAutomatically = false;
            addPeriodWithDoubleSpace = false;
            useSmartQuotesAndDashes = false;
            correctSpellingAutomatically = false;
          };
        };

        sound.soundEffects.playFeedbackWhenVolumeIsChanged = false;
        privacyAndSecurity.appleAdvertising.personalizedAds = false;
      };
    };
  };
}
