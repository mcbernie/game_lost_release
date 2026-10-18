// Download page "Lost": reads the newest published release (pre-releases included) from the
// GitHub API and renders one large download button per platform.
// Inputs: GitHub REST API (unauthenticated, rate limited). Output: DOM of #release-info, #downloads.
// Asset names follow release/package.sh: Lost-<version>-<platform>.{tar.gz,zip}.
(function () {
  "use strict";

  var REPO = "mcbernie/game_lost_release";
  var API = "https://api.github.com/repos/" + REPO + "/releases";
  var ALL = "https://github.com/" + REPO + "/releases";

  /** Platforms in display order; `key` is a substring of the asset name. */
  var PLATFORMS = [
    { key: "linux-x86_64-steamdeck", label: "Steam Deck / Linux" },
    { key: "windows-x86_64", label: "Windows" },
    { key: "macos", label: "macOS" },
  ];

  /** Picks the newest non-draft release by published_at, or null. */
  function pickLatest(releases) {
    var list = (releases || []).filter(function (r) { return !r.draft && r.published_at; });
    list.sort(function (a, b) { return Date.parse(b.published_at) - Date.parse(a.published_at); });
    return list[0] || null;
  }

  /** Finds the download asset of a platform (never the checksum file). */
  function findAsset(release, platform) {
    var assets = release.assets || [];
    for (var i = 0; i < assets.length; i++) {
      if (assets[i].name.indexOf(platform.key) !== -1 && assets[i].name.indexOf("SHA256") === -1) {
        return assets[i];
      }
    }
    return null;
  }

  /** Formats a byte count as "123 MB". */
  function formatSize(bytes) {
    return Math.max(1, Math.round(bytes / (1024 * 1024))) + " MB";
  }

  /** Creates an element with text and optional attributes. */
  function el(tag, text, attrs) {
    var node = document.createElement(tag);
    if (text) node.textContent = text;
    Object.keys(attrs || {}).forEach(function (k) { node.setAttribute(k, attrs[k]); });
    return node;
  }

  /** Shows a readable error with a link to the release list. */
  function showError(message) {
    var info = document.getElementById("release-info");
    var box = document.getElementById("downloads");
    info.textContent = "";
    box.textContent = "";
    var p = el("p", message + " ", { class: "error" });
    p.appendChild(el("a", "Alle Versionen auf GitHub ansehen", { href: ALL }));
    box.appendChild(p);
  }

  /** Renders version line, download buttons and checksum link. */
  function render(release) {
    var info = document.getElementById("release-info");
    var box = document.getElementById("downloads");
    var links = document.getElementById("release-links");
    var date = new Date(release.published_at).toLocaleDateString("de-DE", {
      year: "numeric", month: "long", day: "numeric",
    });
    info.textContent = "Neueste Version: " + release.tag_name + " · " + date + " ";
    if (release.prerelease) {
      info.appendChild(el("span", "Testversion", { class: "badge" }));
    }
    box.textContent = "";
    var found = 0;
    PLATFORMS.forEach(function (platform) {
      var asset = findAsset(release, platform);
      if (!asset) return;
      found++;
      var a = el("a", "", { class: "download", href: asset.browser_download_url });
      a.appendChild(el("span", platform.label, { class: "name" }));
      a.appendChild(el("span", asset.name + " · " + formatSize(asset.size), { class: "size" }));
      box.appendChild(a);
    });
    if (found === 0) {
      showError("In dieser Version wurden keine Pakete gefunden.");
      return;
    }
    links.textContent = "";
    var sums = (release.assets || []).filter(function (a) { return a.name === "SHA256SUMS.txt"; })[0];
    if (sums) {
      links.appendChild(el("a", "SHA256SUMS.txt", { href: sums.browser_download_url }));
      links.appendChild(document.createTextNode(" zum Prüfen der Downloads · "));
    }
    links.appendChild(el("a", "Alle Versionen", { href: ALL }));
    links.hidden = false;
  }

  /** Loads the release list and renders the newest one. */
  function load() {
    fetch(API, { headers: { Accept: "application/vnd.github+json" } })
      .then(function (response) {
        if (!response.ok) throw new Error("HTTP " + response.status);
        return response.json();
      })
      .then(function (releases) {
        var latest = pickLatest(releases);
        if (latest) render(latest);
        else showError("Noch keine veröffentlichte Version vorhanden.");
      })
      .catch(function () {
        showError("Die Versionen konnten gerade nicht geladen werden (Netzwerk oder Abruflimit).");
      });
  }

  load();
})();
